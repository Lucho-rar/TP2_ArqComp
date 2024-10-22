import serial

ser = serial.Serial('COM5', 9600)  

try:
    while True:
        print("Ingrese el operando A: ")
        basura = int(input())       ## lo dejo pa stoppear
        mensaje = 0b00001000
        ser.write(bytes([mensaje]))

        print("Ingrese el operando B: ")
        basura = int(input())           ## lo dejo pa stoppear
        mensaje = 0b00001000
        ser.write(bytes([mensaje]))

        print("Ingrese el codigo de operacion: ")
        basura = int(input())
        mensaje = 0b00100000
        ser.write(bytes([mensaje]))
        
        respuesta_bytes = ser.read(1)  # Lee un byte
        respuesta = int.from_bytes(respuesta_bytes, byteorder='big')  # Interpreta los bytes como un número binario
        print(f'Resultado: {respuesta:08b}')
except KeyboardInterrupt:
    pass

ser.close()
