from PIL import Image
import numpy as np
import base64
import sys
w, h = 512, 512

#print('Argument List:', str(sys.argv))

Hash=sys.argv

#img.show()


def Generate(inputHash):
    print(inputHash)
    Hash=inputHash[1]
    Hash=Hash[2:]

    data = np.zeros((h, w, 3), dtype=np.uint8)
    squareSize=int(512/len(Hash))
    loop=len(Hash)-1
    temp=0
    temp2=0

    TT=int(Hash,16)%3
    print(TT)
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
        
    # red patch in upper left
    #print(data)
    img = Image.fromarray(data, 'RGB')
    #img.show()
    return "created image"

def GenerateB64(inputHash):
    #print(inputHash)
    Hash=inputHash[1]
    Hash=Hash[2:]

    data = np.zeros((h, w, 3), dtype=np.uint8)
    squareSize=int(512/len(Hash))
    loop=len(Hash)-1
    temp=0
    temp2=0

    TT=int(Hash,16)%3
    #print(TT)
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
        
    # red patch in upper left
    #print(data)
    
    return base64.b64encode(data)

#Generate(Hash)
b64Hash = GenerateB64(Hash)
print(b64Hash)