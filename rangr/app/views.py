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
