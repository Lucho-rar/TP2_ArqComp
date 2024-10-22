import serial
import tkinter as tk

ser = serial.Serial('COM5', 9600)       # Serial port 

# initialize the bits for the operands and operation code
bitsA = [0] * 8  # a
bitsB = [0] * 8  # b
bitsOperacion = [0] * 8  # c op

def send_message():
    # convert the bits to integers
    mensajeA = int(''.join(map(str, bitsA)), 2)
    mensajeB = int(''.join(map(str, bitsB)), 2)
    mensajeOperacion = int(''.join(map(str, bitsOperacion)), 2)
    
    # send the message
    ser.write(bytes([mensajeA])) 
    ser.write(bytes([mensajeB])) 
    ser.write(bytes([mensajeOperacion])) 

    # read the response
    respuesta_bytes = ser.read(1)
    respuesta = int.from_bytes(respuesta_bytes, byteorder='big')
    resultado_label.config(text=f'Resultado: {respuesta:08b}')

# update the bit value and label
def update_bit(bits, bit_index, label):
    bits[bit_index] = 1 if bits[bit_index] == 0 else 0 
    label.config(text=f'{bits[bit_index]}') 

# ifaz
root = tk.Tk()
root.title("TP2 - UART") 
root.geometry("600x550") 


root.configure(bg="#E8F0F2")


titulo = tk.Label(root, text="TP2 - UART", font=("Helvetica", 24, "bold"), bg="#E8F0F2", fg="#344955", pady=10)
titulo.pack()

resultado_label = tk.Label(root, text="Resultado: --------", font=("Helvetica", 16), bg="#E8F0F2", fg="#344955")
resultado_label.pack(pady=10)


def create_bit_selector(frame, bits, bit_labels, nombre_operando):
    operando_label = tk.Label(frame, text=nombre_operando, font=("Helvetica", 14), bg="#E8F0F2", fg="#344955")
    operando_label.pack(side=tk.LEFT, padx=10)
    
    for i in range(8):
        frame_column = tk.Frame(frame, bg="#E8F0F2")
        frame_column.pack(side=tk.LEFT, padx=5)


        label = tk.Label(frame_column, text=f'{bits[i]}', font=("Helvetica", 18), width=2, bg="#fff", fg="#344955", bd=2, relief="solid", padx=5, pady=5)
        label.pack(pady=2)


        button = tk.Button(frame_column, text="▲", font=("Helvetica", 12), command=lambda i=i, label=label: update_bit(bits, i, label), 
                           bg="#FF6F61", fg="#fff", relief="flat", width=2, height=1)
        button.pack(pady=2)

        bit_labels.append(label)


operandoA_frame = tk.Frame(root, bg="#E8F0F2")
operandoA_frame.pack(pady=10)
bit_labelsA = []
create_bit_selector(operandoA_frame, bitsA, bit_labelsA, "Operando A")


operandoB_frame = tk.Frame(root, bg="#E8F0F2")
operandoB_frame.pack(pady=10)
bit_labelsB = []
create_bit_selector(operandoB_frame, bitsB, bit_labelsB, "Operando B")


operacion_frame = tk.Frame(root, bg="#E8F0F2")
operacion_frame.pack(pady=10)
bit_labelsOperacion = []
create_bit_selector(operacion_frame, bitsOperacion, bit_labelsOperacion, "Código de Operación")


send_button = tk.Button(root, text="Enviar", font=("Helvetica", 16, "bold"), command=send_message, bg="#4CAF50", fg="#fff", 
                        relief="raised", padx=10, pady=5, bd=4, width=10)
send_button.pack(pady=20)


root.mainloop()


ser.close()
