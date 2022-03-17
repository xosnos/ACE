import os, time
from django.conf import settings
from django.core.files.storage import FileSystemStorage
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
import json
from django.db import connection

def get_test(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    cursor = connection.cursor()
    cursor.execute('SELECT * FROM test ORDER BY time DESC;')
    rows = cursor.fetchall()

    response = {}
    response['data'] = rows
    return JsonResponse(response)

@csrf_exempt
def post_test(request):

    if request.method != 'POST':
        return HttpResponse(status=400)

    # loading form-encoded data
    username = request.POST.get("username")
    message = request.POST.get("message")

    if request.FILES.get("video"):
        content = request.FILES['video']
        filename = username+str(time.time())+".mov"
        fs = FileSystemStorage()
        filename = fs.save(filename, content)
        videourl = fs.url(filename)
    else:
        videourl = None

    cursor = connection.cursor()
    cursor.execute('INSERT INTO test (username, message, videourl) VALUES '
                   '(%s, %s, %s);', (username, message, videourl))

    return JsonResponse({})
# Create your views here.
def get_shot_data(request, user_id):
    if request.method != 'GET':
        return HttpResponse(status=404)
    cursor = connection.cursor()
    print("DEBUG: ", user_id)
    # this syntax is probably wrong
    #user_id = request.GET.get("user_id")
    # I think I should the user_id a query parameter. So different url for a given user
    query = """SELECT launch_angle, launch_speed, hang_time, distance, shot_id
            FROM users U, shots S
            WHERE S.user_id = %s
            ORDER BY time DESC
            LIMIT 1;"""

    cursor.execute(query,[user_id])
    rows = cursor.fetchall()

    response = {}
    response['data'] = rows
    return JsonResponse(response)

@csrf_exempt
def post_shot_data(request):

    # it won't look like this in the end, we'll get the data from CV stuff, not the request

    if request.method != 'POST':
        return HttpResponse(status=404)
    json_data = json.loads(request.body)
    user_id = json_data['user_id']
    launch_angle = json_data['launch_angle']
    launch_speed = json_data['launch_speed']
    hang_time = json_data['hang_time']
    distance = json_data['distance']
    cursor = connection.cursor()
    query = """INSERT INTO shots (user_id, launch_angle, launch_speed, hang_time, distance)
            VALUES (%s, %s, %s, %s, %s);"""
    cursor.execute(query, (user_id, launch_angle, launch_speed, hang_time, distance))
    return JsonResponse({})
