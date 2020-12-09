(import (chicken format)
        (chicken string)
        (chicken io)
        srfi-113
        srfi-128)

(call-with-input-file "inputs/smallinput"
  (lambda (p)
    (let* ((results '())
           (comp (make-default-comparator))
           (currgroupset (set comp))
           (currsets '()))
      (let floop ((l (read-line p)))
             (cond ((eof-object? l) (close-input-port p))
               ((string=? l "")   (set! currgroupset (apply set-intersection currsets))
                                  (set! results (append results (list currgroupset)))
                                  (set! currgroupset (set comp))
				  (set! currsets '())
                                  (floop(read-line p)))
               (else  (let ((currset (set comp)))
                        (foldr (lambda (x acc)
                                (set-adjoin! currset x)) '() (string->list (string-chomp l)))
                        (set! currsets (append currsets (list currset))))
                     (floop (read-line p)))))
     (format #t "read ~A sets ~A ~%" (length results) results)
     (format #t "total uniq ~A ~%" 
       (foldr (lambda (x acc) 
                (if (set? x) 
                    (+ acc (set-size x)))) 
              0 results)))))

; oneliner part 1
(call-with-input-file "inputs/input" (lambda (p) (foldr (lambda (x acc) (if (null? x) (cons (+ (car acc) (length (cdr acc))) '()) (cons (car acc) (lset-union eq? (cdr acc) x)))) (cons 0 '()) (map string->list (read-lines p)))))
