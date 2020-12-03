(import format)
(import srfi-1)
(import (chicken io))

(define (shiftlist lst) 
  (append (cdr lst) (list (car lst))))

(define (allpairs lst)
  (letrec* ((tmp lst)
            (res '())
            (loop (lambda (i)
              (if (> i 0)
                  (begin 
                    (set! res (append res (zip lst tmp)))
                    (set! tmp (shiftlist tmp))
                    (loop (- i 1)))))))
    (loop (length lst))
    res))

#| 
(define (alltriples lst)
  (letrec* ((tmp lst)
            (tmp1 lst)
            (res '())
            (loop (lambda (i j)
              (if (> j 0)
                  (begin 
                    (set! res (append res (zip lst tmp tmp1)))
                    (set! tmp (shiftlist tmp))
                    (if (> i 0) 
                        (loop (- i 1) j))
                        (begin 
                          (set! tmp1 (shiftlist tmp1))
                          (loop (length lst) (- j 1))))))))
    (loop (length lst) (length lst))
    res)) 
|#

(call-with-input-file "inputs/smallinput"
  (lambda (port)
    (let* ((strdata (read-lines port))
           (data (map string->number strdata))
           (allp (allpairs data)))
      (format #t 
              "all pairs with sum 2020: ~A~%" 
              (filter (lambda (x)
                        (= 2020 (reduce + 0 x))) 
                      allp))
      (format #t "all triplets : ~A~%"
        (map (lambda (x)
               (filter (lambda (y) 
                         (= (- 2020 x) 
                            (reduce + 0 y))) 
                       allp)) 
              data)))))
                
