; This copy of codes has Data Hazard in it
; You should do something to avoid it
lw $1, 40($0)	; 1
lw $2, 44($0)	; 5
lw $3, 48($0)	; 8
add $4, $1, $2	; $4=6
sub $5, $3, $1	; $5=7
and $6, $2, $1	; $6=1
lw $10, 40($0)	; 1
lw $10, 40($0)	; 1
lw $10, 40($0)	; 1 
or $7, $3, $1	; $7=9
slt $8, $3, $1	; $8=0
beq $0, $0, end	; to end
add $9, $7, $8	; $9=9, not executed
end:
lw $10, 40($0)	; 1
lw $10, 40($0)	; 1
lw $10, 40($0)	; 1
lw $10, 40($0)	; 1
lw $10, 40($0)	; 1