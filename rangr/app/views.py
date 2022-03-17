import os, time
from django.conf import settings
from django.core.files.storage import FileSystemStorage
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
import json
from django.db import connection


import numpy as np
import cv2
import math

# get the most recent shot taken by the user
def get_user_last_shot(request, user_id):
    if request.method != 'GET':
        return HttpResponse(status=404)
    cursor = connection.cursor()
    query = """SELECT launch_angle, launch_speed, hang_time, distance, club, time
            FROM users U, shots S
            WHERE S.user_id = %s
            ORDER BY time DESC
            LIMIT 1;
            """

    cursor.execute(query,[user_id])
    rows = cursor.fetchall()

    response = {'data': rows}
    return JsonResponse(response)


# post shot takes in a userid, hand, club, and a video file
@csrf_exempt
def post_shot(request):

    if request.method != 'POST':
        return HttpResponse(status=400)

    # load the user_id, club, and handedness
    user_id = request.POST.get("user_id")
    club = request.POST.get("club")
    hand = request.POST.get("hand")

    # load the video if it exists. 
    if request.FILES.get("video"):
        content = request.FILES['video']
        filename = str(user_id) + str(time.time()) + ".mov"
        fname = filename
        fs = FileSystemStorage()
        filename = fs.save(filename, content)
        # videourl = fs.url(filename)
    else:
        return JsonResponse({})

    # get shot data for given video url
    #data = get_shot_metrics(f"~/ACE/rangr/media/11647555259.3231792.mov/", hand)
    data = get_shot_metrics(f"{settings.MEDIA_ROOT}/{fname}", hand)
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

    return JsonResponse({})

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
    # for i in range(len(xs)):
    #     print(xs[i], ys[i])
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
        # print('no start point found')
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
    distance = round(distance)
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
    # print(x, y , radius)
    # find unit of distance in one pixel
    pix_to_inches = (1.68 / 2) / radius
    # find the ball's launch angle using the first 2 points
    metrics['launch_angle'] = get_launch_angle(x[0], y[0], x[1], y[1])
    # find the ball's launch speed using the last 2 points and pix_to_inches to account for start time
    metrics['launch_speed'] = get_launch_speed(x[-2], y[-2], x[-1], y[-1], pix_to_inches)
    # find the distance traveled by the ball using all of the points and pix_to_inches
    metrics['hang_time'] = get_hang_time(metrics['launch_angle'], metrics['launch_speed'])
    # find the distance using hangtime, launch angle, and speed
    metrics['distance'] = get_distance(metrics['hang_time'], metrics['launch_angle'], metrics['launch_speed'])
    return metrics
