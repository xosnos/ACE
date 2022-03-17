import os, time
from django.conf import settings
from django.core.files.storage import FileSystemStorage
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
import json
from django.db import connection
from cv_rangr import get_shot_metrics

# get the most recent shot taken by the user
def get_user_last_shot(request, user_id):
    if request.method != 'GET':
        return HttpResponse(status=404)
    cursor = connection.cursor()
    query = """SELECT launch_angle, launch_speed, hang_time, distance, club
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
        fs = FileSystemStorage()
        filename = fs.save(filename, content)
        # videourl = fs.url(filename)
    else:
        return JsonResponse({})

    # get shot data for given video url
    data = get_shot_metrics(f"rangr/media/{filename}", hand)
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