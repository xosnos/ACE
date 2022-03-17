import numpy as np
import cv2
import matplotlib.pyplot as plt
import matplotlib
import math

# fix issue with saving plots...
matplotlib.use('Agg')


def show_ball_path(filename):
    # take a video file as input
    video = cv2.VideoCapture(filename)
    # convert video into a list of frames
    frames = []
    while True:
        (grabbed, frame) = video.read()
        if not grabbed:
            break
        # scale_percent = 50 # percent of original size
        # width = int(frame.shape[1] * scale_percent / 100)
        # height = int(frame.shape[0] * scale_percent / 100)
        # dim = (width, height)
        # # resize image
        # frame = cv2.resize(frame, dim, interpolation = cv2.INTER_AREA)
        frames.append(frame)
    # print(f'video loaded with {len(frames)} frames')
    # for each frame, find the yellow colored ball
    lower = (29, 122, 60) # good 
    upper = (45, 255, 255) # good
    for i in range(len(frames)):
        frame = frames[i]
        # use threshold to find the yellow colored ball
        hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
        mask = cv2.inRange(hsv, lower, upper)
        # find the contours of the frame
        contours = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)[-2]
        # if no contours found, skip this frame
        if len(contours) == 0:
            continue
        # find the largest contour in the mask
        c = max(contours, key=cv2.contourArea)
        ((x, y), radius) = cv2.minEnclosingCircle(c)
        M = cv2.moments(c)
        # draw a red circle around the largest contour
        cv2.circle(frame, (int(x), int(y)), int(radius), (0, 0, 255), -1)
        # 297 323
        # store the frame back into the frames list
        frames[i] = frame



    # after all frames are processed, assemble the video as mp4 file
    if(len(frames)) > 0:
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        out = cv2.VideoWriter(f"{filename}_output.mp4", fourcc, 5.0, (frames[0].shape[1], frames[0].shape[0]))
        for frame in frames:
            out.write(frame)
        out.release()


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
    # else:
    #     # plot each point on a figure
    #     plt.plot(xs, ys, 'ro-')
    #     # save the figure
    #     plt.savefig(f'{filename}.png')
     
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

# main function
if __name__ == "__main__":
    # video file
    # filenames is 1-10.mov
    # filenames = ['1.mov', '2.mov', '3.mov', '4.mov', '5.mov', '6.mov',
    # '7.mov', '8.mov', '9.mov', '10.mov']
    # filenames = ['Backend/6.MOV']
    filenames = ['rangr/media/lklaus1647402281.2473774.mov']
    # filenames = ['10.mov']
    # for filename in filenames:
    #     # get the points of the ball and the radius of the largest contour
    #     points = get_ball_points(filename)
    #     if points == -1:
    #         print(filename, "error")
    #     else:
    #         x = points[0]
    #         y = points[1]
    #         radius = points[2]
    #         print(filename, x, y, radius)

    #     # show ball movement over video
        # show_ball_path(filename)
    print('degrees, mph, seconds, yards')
    for filename in filenames:
        print(filename, get_shot_metrics(filename, 'right'))

        
# 297, 323
# 450, 440
points = ([297, 450] , [323, 440], 10)