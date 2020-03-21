from PIL import Image
import numpy as np
import base64, sys
from io import BytesIO


def Generate(inputHash, w=512, h=512):
    Hash=inputHash[2:]

    data = np.zeros((h, w, 3), dtype=np.uint8)
    squareSize=int(512/len(Hash))
    loop=len(Hash)-1
    temp=0
    temp2=0

    TT=int(Hash,16)%3
    for x in range(0,loop):
        color=int(Hash[x:x+2],16)
        for y in range(0,loop):
            color2=int(Hash[y:y+2],16)
            temp2=y*squareSize
            if TT==0:
                data[temp2:temp2+squareSize, temp:temp+squareSize]= [(color2*color)%256, (256-(color*(color2)))%256,0] 
            if TT==1:
                data[temp2:temp2+squareSize, temp:temp+squareSize]= [(color2*color)%256,0, (256-(color*(color2)))%256]
            if TT==2:
                data[temp2:temp2+squareSize, temp:temp+squareSize]= [0,(color2*color)%256, (256-(color*(color2)))%256]
        temp+=squareSize

    img = Image.fromarray(data, 'RGB')
    stream = BytesIO()
    img.save(stream, format='png')
    return base64.b64encode(stream.getvalue()).decode()


def main_handler(event, context):
    return {
        "statusCode": 200,
        "headers": { "Content-type": "image/png" },
        "body": Generate(event['pathParameters']['hash'], w=512, h=512),
        "isBase64Encoded": True
    }
