.global factorial

factorial:
    mov x9, x0          // number
    mov x10, #1         // neutral value

rec:
    cbz x9, end_rec     // if num == 0 end
    mul x10, x10, x9    // num *= (num-1)
    add x9, x9, #-1     // num--
    b rec

end_rec:
    mov x0, x10         // return factorial(number)
    ret


