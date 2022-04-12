import os, time
from django.conf import settings
from django.core.files.storage import FileSystemStorage
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
import json
from django.db import connection


import datetime
import numpy as np
import cv2
import math
import hashlib
import uuid
    

# takes in user and number of shots you want
# Ex. /get_shot_log/1/10
def get_shot_log(request, user_id, number):
    if request.method != 'GET':
        return HttpResponse(status=404)
    cursor = connection.cursor()
    if user_id == 0:
        return JsonResponse({'data': []})
    return_array = []
    query = """SELECT DISTINCT time, club, distance, launch_speed, launch_angle, hang_time
            FROM shots S
            WHERE S.user_id = %s
            ORDER BY time DESC
            LIMIT %s;
        """
    cursor.execute(query, (user_id, number,))
    rows = cursor.fetchall()
    for row in rows:
        small_dict = {}
        small_dict["time"] = row[0]
        small_dict["club"] = row[1]
        small_dict["distance"] = row[2]
        small_dict["launch_speed"] = row[3]
        small_dict["launch_angle"] = row[4]
        small_dict["hang_time"] = row[5]
        return_array.append(small_dict)
    response = {'data': return_array}
    return JsonResponse(response)

# get the most recent shot taken by the user
# take user_id as url. /get_user_last_shot/X
def get_user_last_shot(request, user_id):
    if request.method != 'GET':
        return HttpResponse(status=404)
    cursor = connection.cursor()

    current_time = datetime.datetime.now() - datetime.timedelta(minutes=1)

    return_dict = {}
    query = """SELECT DISTINCT launch_angle, launch_speed, hang_time, distance, club, time
            FROM shots S
            WHERE S.user_id = %s AND S.time > %s
            ORDER BY time DESC
            LIMIT 1;
            """

    cursor.execute(query,(user_id, current_time))
    rows = cursor.fetchall()

    if len(rows) == 0:
        return_dict["launch_angle"] = "N/A"
        return_dict["launch_speed"] = "N/A"
        return_dict["hang_time"] ="N/A"
        return_dict["distance"] = "N/A"
        return_dict["club"] = "N/A"
        return_dict["time"] = "N/A"
    
    else:
        return_dict["launch_angle"] = rows[0][0]
        return_dict["launch_speed"] = rows[0][1]
        return_dict["hang_time"] = rows[0][2]
        return_dict["distance"] = rows[0][3]
        return_dict["club"] = rows[0][4]
        return_dict["time"] = rows[0][5]

    return JsonResponse(return_dict)


@csrf_exempt
def account_create(request):
    """Create account by adding username and password to DB."""
    if request.method != 'POST':
        return HttpResponse(status=400)
    
    
    username = request.GET.get("username")
    pwd = request.GET.get("password")


    # Empty argument checking
    if not username or not pwd:
        return HttpResponse(status=400)

    # See if username already exists
    cursor = connection.cursor()
    query = """SELECT username, user_id, password
            FROM users u
            WHERE u.username = %s;
            """
    
    cursor.execute(query,[username])
    rows = cursor.fetchall()

    if len(rows) != 0:
        return HttpResponse(status=409)

    # Generate hashed password
    algo = 'sha512'
    salt = uuid.uuid4().hex
    hash_obj = hashlib.new(algo)
    salted_pwd = salt + pwd
    hash_obj.update(salted_pwd.encode('utf-8'))
    hashed_pwd = hash_obj.hexdigest()
    db_pwd = '$'.join([algo, salt, hashed_pwd])

    # Create user in db and return new user_id
    query = """INSERT INTO users
            (username, password)
            VALUES (%s, %s);

            SELECT user_id
            FROM users
            WHERE username = %s;
            """
    cursor.execute(query, (username, db_pwd, username))
    rows = cursor.fetchall()
    if len(rows) == 0:
        return HttpResponse(status=403)
    user_id = rows[0][0]

    return JsonResponse({'user_id': user_id})


@csrf_exempt
def account_login(request):
    """Login to account and return user_id."""
    if request.method != 'POST':
        return HttpResponse(status=400)

    username = request.GET.get("username")
    pwd = request.GET.get("password")

    # Empty argument checking
    if not username or not pwd:
        return HttpResponse(status=400)

    # See if user exists
    cursor = connection.cursor()
    query = """SELECT username, user_id, password
            FROM users u
            WHERE u.username = %s;
            """
    
    cursor.execute(query,[username])
    rows = cursor.fetchall()

    # User doesn't exist
    if len(rows) == 0:
        return HttpResponse(status=403)

    _, user_id, db_pwd = rows[0]

    # Password comparison
    algo_db_pwd, salt_db_pwd, hashed_db_pwd = db_pwd.split('$')
    hash_obj = hashlib.new(algo_db_pwd)

    salted_pwd = salt_db_pwd + pwd
    hash_obj.update(salted_pwd.encode('utf-8'))
    hashed_pwd = hash_obj.hexdigest()

    # Incorrect password
    if hashed_pwd != hashed_db_pwd:
        return HttpResponse(status=403)
    
    # Successful login, return user_id
    return JsonResponse({'user_id': rows[0][1]})


# post shot takes in a userid, hand, club, and a video file
@csrf_exempt
def post_shot(request):
    if request.method != 'POST':
        return HttpResponse(status=400)

    # load the user_id, club, and handedness
    user_id = request.POST.get("user_id")
    club = request.POST.get("club")
    hand = request.POST.get("hand")

    if not user_id or not club or not hand:
        return HttpResponse(status=403)

    # load the video if it exists. 
    #if request.FILES.get("video"):
    content = request.FILES["video"]
    filename = str(user_id) + str(time.time()) + ".mov"
    fname = filename
    fs = FileSystemStorage()
    filename = fs.save(filename, content)
    # videourl = fs.url(filename)

    # get shot data for given video url
    #data = get_shot_metrics(f"~/ACE/rangr/media/11647555259.3231792.mov/", hand)
    data = get_shot_metrics(f"{settings.MEDIA_ROOT}/{fname}", hand)
    if data['launch_speed'] == -1 or data['launch_angle'] == -1 or data['distance'] == -1 or data['hang_time'] == -1:
        for key in data:
            data[key] = 'N/A'
        data['club'] = str(club)
        data['hand'] = str(hand)
        for i in data:
            data[i] = str(data[i])

        return JsonResponse(data)
        # return HttpResponse(status=401)

    launch_speed = float(data['launch_speed'])
    launch_angle = float(data['launch_angle'])
    distance = float(data['distance'])
    hang_time = float(data['hang_time'])
    
    

    # get the user id for the user
    
    cursor = connection.cursor()
    query = """INSERT INTO shots
                (user_id, launch_speed, launch_angle, hang_time, distance,
                club, hand)
                VALUES (%s, %s, %s, %s, %s, %s, %s);
            """
    cursor.execute(query, (user_id, launch_speed, launch_angle, hang_time, distance, club, hand))

    data['club'] = str(club)
    data['hand'] = str(hand)
    for i in data:
        data[i] = str(data[i])
    return JsonResponse(data)


# plot ball path
def get_ball_points(filename, hand):
    # take a video file as input
    video = cv2.VideoCapture(filename)
    # range of yellow in hsv
    lower = (29, 122, 60)
    upper = (45, 255, 255)
    # keep track of largest contour location and radius
    xs = []
    ys = []
    radii = []
    # take video frame by frame
    while True:
        (grabbed, frame) = video.read()
        if frame is None:
            # return x,y,radius
            break
        # reduce the size by a factor of 2
        # scale_percent = 50
        # width = int(frame.shape[1] * scale_percent / 100)
        # height = int(frame.shape[0] * scale_percent / 100)
        # dim = (width, height)
        # # resize image
        # frame = cv2.resize(frame, dim, interpolation = cv2.INTER_AREA)
        # convert to hsv
        frame = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
        # create a mask using the range of yellow
        frame = cv2.inRange(frame, lower, upper)
        # find the contours of the frame
        contours = cv2.findContours(frame, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)[-2]
        # if no contours found, skip this frame
        if len(contours) == 0:
            continue
        # find the largest contour in the mask
        c = max(contours, key=cv2.contourArea)
        ((x, y), radius) = cv2.minEnclosingCircle(c)
        # if radius is larger than 20, find the next largest contour if one exists

        xs.append(round(x))
        ys.append(round(frame.shape[0] - y))
        radii.append(round(radius))

    ## obtain the x and y coordinates of the ball in motion
    # plot the ball path if we found at least 20 contours
    if len(xs) > 20 and hand == 'right':
        # look for a series of 3 points where y is increasing
        for i in range(len(ys) - 3):
            if ys[i] < ys[i+1] and ys[i+1] < ys[i+2] and xs[i] < xs[i+1] and xs[i+1] < xs[i+2]:
                # we found the first point
                xs = xs[i:i+3]
                ys = ys[i:i+3]
                radii = radii[i:i+3]
                break
                
    if len(xs) > 20 and hand == 'left':
        # look for a series of 3 points where y is increasing
        for i in range(len(ys) - 3):
            if ys[i] < ys[i+1] and ys[i+1] < ys[i+2] and xs[i] > xs[i+1] and xs[i+1] > xs[i+2]:
                # we found the first point
                xs = xs[i:i+3]
                ys = ys[i:i+3]
                radii = radii[i:i+3]
                break

    # if we couldn't find three consecutive points, loop for 2 consecutive 
    # increasing points moving in the correct direction based on the hand
    if len(xs) > 20 and hand == 'right':
        for i in range(len(ys) - 2):
            if ys[i] < ys[i+1] and xs[i] < xs[i+1] and radii[i] < 40:
                # we found the first point
                xs = xs[i:i+2]
                ys = ys[i:i+2]
                radii = radii[i:i+2]
                break
    if len(xs) > 20 and hand == 'left':
        for i in range(len(ys) - 2):
            if ys[i] < ys[i+1] and xs[i] > xs[i+1] and radii[i] < 40:
                # we found the first point
                # invert the points as if the hand was right
                # and the ball moves up to the right instead of up to the left
                xs = [xs[i+1], xs[i]]
                ys = [ys[i], ys[i+1]]
                radii = radii[i:i+2]
                break
    # if we still haven't found a series of points, this video will not work
    if len(xs) > 20:
        return -1
    # return points and minimum radius
    radii = min(radii)
    return (xs, ys, radii)




def get_launch_angle(x1, y1, x2, y2):
    # find the angle between the two points
    angle = math.atan2(y2 - y1, x2 - x1)
    # convert to degrees
    angle = math.degrees(angle)
    # round angle to nearest tenth
    angle = round(angle, 1)
    # return the angle
    return angle

def get_launch_speed(x1, y1, x2, y2, pix_to_inches):
    # find the distance between the two points
    distance = math.sqrt((x2 - x1)**2 + (y2 - y1)**2)
    # convert to inches
    distance = distance * pix_to_inches
    # calculate speed using frame time = (1/60) seconds
    speed = distance / (1/60)
    # convert inches / second to mph
    speed = speed / 17.6
    # round the speed to nearest tenth
    speed = round(speed, 1)
    return speed

def get_hang_time(angle, speed):
    # convert speed to meters per second
    speed = speed / 2.237
    # find the y component of velocity of the ball
    y_velocity = speed * math.sin(math.radians(angle))
    # find the time it takes to hit the ground
    # verticl position formula to solve: 0 = -g(t^2) + y_iv(t)
    # divide both sides by t:  0 = -g(t) + y_iv
    # solve for t: gt = y_iv
    # solve for t: t = y_iv / g
    hang_time = y_velocity / 9.81
    # round to nearest tenth
    hang_time = round(hang_time, 1)
    return hang_time

def get_distance(hang, angle, speed):
    # convert speed from mph to mps
    speed = speed / 2.237
    # find the x component of velocity of the ball
    x_velocity = speed * math.cos(math.radians(angle))
    # calculate the horizontal distance travelled over hang time
    distance = hang * x_velocity
    # convert distance from meters to yards
    distance = distance * 1.094
    # round distance to nearest yard
    distance = round(distance, 1)
    return distance



def get_shot_metrics(filename, hand):
    metrics = {'launch_angle': -1, 'launch_speed': -1, 'hang_time': -1, 'distance': -1}
    # get the points of the ball and the radius of the largest contour
    points = get_ball_points(filename, hand)
    if points == -1:
        # invalid video
        return metrics
    # isolate the x and y coordinates of the ball
    x = points[0]
    y = points[1]
    radius = points[2]
    # find unit of distance in one pixel
    pix_to_inches = (1.68 / 2) / radius
    # find the ball's launch angle using the first 2 points
    metrics['launch_angle'] = get_launch_angle(x[0], y[0], x[1], y[1])
    # find the ball's launch speed using the last 2 points and pix_to_inches to account for start time
    metrics['launch_speed'] = get_launch_speed(x[-2], y[-2], x[-1], y[-1], pix_to_inches)
    # find the distance traveled by the ball using all of the points and pix_to_inches
    metrics['hang_time'] = get_hang_time(metrics['launch_angle'], metrics['launch_speed'])
    # find the distance using hangtime, launch angle, and speed
    metrics["distance"] = get_distance(metrics['hang_time'], metrics['launch_angle'], metrics['launch_speed'])
    return metrics
