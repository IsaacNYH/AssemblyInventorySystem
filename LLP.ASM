.model small
.386
.stack 100h

.data
menu db 'Inventory Management System', 0Dh, 0Ah
  db '1. View Inventory', 0Dh, 0Ah
  db '2. Record Sale', 0Dh, 0Ah
  db '3. Restock Items', 0Dh, 0Ah
  db '4. View Sales', 0Dh, 0Ah
  db '5. View Restocks', 0Dh, 0Ah
  db '6. Exit', 0Dh, 0Ah, '$'
prompt db 'Select an option: $'
newline db 0Dh, 0Ah, '$'
space db 0Dh, 0Ah, 0Dh, 0Ah, '$' ; Extra space between items
invalid db 'Invalid option. Try again.', 0Dh, 0Ah, '$'
view_msg db 'Viewing Inventory...', 0Dh, 0Ah, '$'
record_msg db 'Recording Sale...', 0Dh, 0Ah, '$'
restock_msg db 'Restocking Items...', 0Dh, 0Ah, '$'
view_sales_msg db 'Viewing Sales...', 0Dh, 0Ah, '$'
view_restocks_msg db 'Viewing Restocks...', 0Dh, 0Ah, '$'
sale_prompt db 'Enter item number to record sale: $'
quantity_prompt db 'Enter quantity to deduct: $'
restock_prompt db 'Enter item number to restock: $'
restock_quantity_prompt db 'Enter quantity to add: $'
sale_confirm db 'Sale recorded.', 0Dh, 0Ah, '$'
restock_confirm db 'Restock recorded.', 0Dh, 0Ah, '$'
invalid_item_msg db 'Invalid item number. Try again. $'
invalid_quantity_msg db 'Invalid quantity. Try again. $'
low_stock_msg db 'Warning: Stock is low for this item!', 0Dh, 0Ah, '$'
item_number_msg db 'Item ', '$'
quantity_msg db ', Quantity: ', '$'

; Arrays for items and quantities
item_labels db 'Item1: CPUs $', 0Dh, 0Ah
             db 'Item2: GPUs $', 0Dh, 0Ah
             db 'Item3: HDDs $', 0Dh, 0Ah
             db 'Item4: RAMs $', 0Dh, 0Ah
             db 'Item5: SSDs $', 0Dh, 0Ah
item_qty db 5, 5, 5, 5, 5

item_counter db 5 ; Number of existing items

; New arrays for sales and restocks
sales_qty db 5 dup(0)
restocks_qty db 5 dup(0)

.code
main proc
  mov ax, @data
  mov ds, ax

main_loop:
  ; Clear screen
  mov ah, 09h
  lea dx, newline
  int 21h

  ; Display menu
  lea dx, menu
  mov ah, 09h
  int 21h

  ; Prompt user
  lea dx, prompt
  mov ah, 09h
  int 21h

  ; Get user input
  mov ah, 01h
  int 21h
  sub al, '0' ; Convert from ASCII to number

  ; Handle user input
  cmp al, 1
  je view_inventory
  cmp al, 2
  je record_sale
  cmp al, 3
  je restock_items
  cmp al, 4
  je view_sales
  cmp al, 5
  je view_restocks
  cmp al, 6
  je exit_program

  ; Invalid option
  call invalid_option
  jmp main_loop

view_inventory:
  ; Display inventory header
  lea dx, newline
  mov ah, 09h
  int 21h
  lea dx, view_msg
  mov ah, 09h
  int 21h

  ; Display all items using a single procedure
  mov si, offset item_labels
  mov di, offset item_qty
  mov cl, item_counter

display_loop:
  ; Display item label
  lea dx, [si]
  mov ah, 09h
  int 21h

  ; Display item quantity
  mov al, [di]
  add al, '0'          ; Convert number to ASCII
  mov dl, al
  mov ah, 02h
  int 21h

  ; Check for low stock
  call check_low_stock

  ; Add space between items
  lea dx, space
  mov ah, 09h
  int 21h

  ; Move to next item
  add si, 15           ; Length of each item label + newline
  inc di
  dec cl
  jnz display_loop

  ; Return to main loop
  jmp main_loop

check_low_stock proc
  ; Check if quantity is less than 3
  cmp al, '3'
  jae skip_low_stock
  ; Add newline and display low stock warning
  lea dx, newline
  mov ah, 09h
  int 21h
  lea dx, low_stock_msg
  mov ah, 09h
  int 21h
skip_low_stock:
  ret
check_low_stock endp

record_sale:
  ; Record sale
  lea dx, newline
  mov ah, 09h
  int 21h
  lea dx, record_msg
  mov ah, 09h
  int 21h

  ; Ask for item number
  lea dx, sale_prompt
  mov ah, 09h
  int 21h

  ; Get item number
  mov ah, 01h
  int 21h
  sub al, '0' ; Convert from ASCII to number
  dec al       ; Convert to zero-based index
  mov bl, al  ; Store item number in bl

  ; Check if item number is valid
  cmp bl, item_counter
  jae invalid_item

  ; Ask for quantity
  lea dx, newline
  mov ah, 09h
  int 21h
  lea dx, quantity_prompt
  mov ah, 09h
  int 21h

  ; Get quantity
  mov ah, 01h
  int 21h
  sub al, '0' ; Convert from ASCII to number
  mov cl, al  ; Store quantity in cl

  ; Deduct quantity from inventory
  call deduct_item
  call update_sales

  jmp main_loop

deduct_item proc
  ; Deduct quantity from the item based on item number in bl
  mov si, offset item_qty
  add si, bx
  mov al, [si]
  sub al, cl
  cmp al, 0
  jl invalid_quantity ; Check if quantity to deduct is valid
  mov [si], al
  call sale_recorded
  ret
deduct_item endp

update_sales proc
  mov si, offset sales_qty
  add si, bx
  mov al, [si]
  add al, cl
  mov [si], al
  ret
update_sales endp

restock_items:
  ; Restock items
  lea dx, newline
  mov ah, 09h
  int 21h
  lea dx, restock_msg
  mov ah, 09h
  int 21h

  ; Ask for item number
  lea dx, restock_prompt
  mov ah, 09h
  int 21h

  ; Get item number
  mov ah, 01h
  int 21h
  sub al, '0' ; Convert from ASCII to number
  dec al       ; Convert to zero-based index
  mov bl, al  ; Store item number in bl

  ; Check if item number is valid
  cmp bl, item_counter
  jae invalid_item

  ; Ask for quantity
  lea dx, newline
  mov ah, 09h
  int 21h
  lea dx, restock_quantity_prompt
  mov ah, 09h
  int 21h

  ; Get quantity
  mov ah, 01h
  int 21h
  sub al, '0' ; Convert from ASCII to number
  mov cl, al  ; Store quantity in cl

  ; Add quantity to inventory
  call add_item
  call update_restocks

  jmp main_loop

add_item proc
  ; Add quantity to the item based on item number in bl
  mov si, offset item_qty
  add si, bx
  mov al, [si]
  add al, cl
  mov [si], al
  call restock_recorded
  ret
add_item endp

update_restocks proc
  mov si, offset restocks_qty
  add si, bx
  mov al, [si]
  add al, cl
  mov [si], al
  ret
update_restocks endp

view_sales:
  ; Display sales header
  lea dx, newline
  mov ah, 09h
  int 21h
  lea dx, view_sales_msg
  mov ah, 09h
  int 21h

  ; Display all sales
  mov si, offset sales_qty
  mov cl, item_counter
  mov bl, 1 ; Item number counter

display_sales_loop:
  call display_item_quantity
  inc bl
  inc si
  dec cl
  jnz display_sales_loop

  jmp main_loop

view_restocks:
  ; Display restocks header
  lea dx, newline
  mov ah, 09h
  int 21h
  lea dx, view_restocks_msg
  mov ah, 09h
  int 21h

  ; Display all restocks
  mov si, offset restocks_qty
  mov cl, item_counter
  mov bl, 1 ; Item number counter

display_restocks_loop:
  call display_item_quantity
  inc bl
  inc si
  dec cl
  jnz display_restocks_loop

  jmp main_loop

display_item_quantity proc
  ; Display item number
  lea dx, item_number_msg
  mov ah, 09h
  int 21h
  mov dl, bl
  add dl, '0'
  mov ah, 02h
  int 21h

  ; Display quantity message
  lea dx, quantity_msg
  mov ah, 09h
  int 21h

  ; Display quantity
  mov al, [si]
  add al, '0'
  mov dl, al
  mov ah, 02h
  int 21h

  ; Add newline
  lea dx, newline
  mov ah, 09h
  int 21h

  ret
display_item_quantity endp

invalid_item:
  lea dx, invalid_item_msg
  mov ah, 09h
  int 21h
  ret

invalid_quantity:
  lea dx, invalid_quantity_msg
  mov ah, 09h
  int 21h
  ret

invalid_option:
  lea dx, invalid
  mov ah, 09h
  int 21h
  ret

sale_recorded:
  lea dx, sale_confirm
  mov ah, 09h
  int 21h
  ret

restock_recorded:
  lea dx, restock_confirm
  mov ah, 09h
  int 21h
  ret

exit_program:
  ; Exit program
  mov ah, 4Ch
  int 21h

main endp
end main