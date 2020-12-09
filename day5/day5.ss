(import (chicken io)
        (chicken sort)
        (chicken format))

(define (ardiv low high d)
  (case d
    ((#\l) (cons low (+ low (floor (/ (- high low) 2))) ))
    ((#\h) (cons (- high (floor (/ (- high low) 2))) high))))

(define (seatid rc)
  (+ (* (car rc) 8) (cdr rc)))

(define (calcSeat str)
  (let* ((sparts (string-chop str 7))
         (rowdirs (string-translate* (car sparts) '(("F" . "l") ("B" . "h"))))
         (cdirs (string-translate* (cadr sparts) '(("L" . "l")("R" . "h"))))
         (frow '())
         (fcol '()))
    (set! frow 
          (car (foldr (lambda (x acc)
                        (format #f "ardiv with low:~A high:~A dir:~A~%" (car acc) (cdr acc) x)
                        (ardiv (car acc) (cdr acc) x))
                      (cons 0 127) (reverse (string->list rowdirs)))))
    (set! fcol 
          (car (foldr (lambda (x acc)
                        (format #f "ardiv with low:~A high:~A dir:~A~%" (car acc) (cdr acc) x)
                        (ardiv (car acc) (cdr acc) x))
                      (cons 0 7) (reverse (string->list cdirs)))))
    (seatid (cons frow fcol))))

(define seats 
  (call-with-input-file "inputs/input"
                         (lambda (p) (map calcSeat (read-lines p)))))

; to get the seat thake the car of sorted
(format #t "highest seat ~A~%" (car (sort seats >)))
;to get your seat you find th one who is not in sequence in the sorted list
(foldr (lambda (x val) (if (not (= x (+ val 1))) (begin (format #t "your seat is ~A~%" (- x 1)) (error))) (+ val 1)) 90 (sort seats >))
