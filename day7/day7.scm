(import (chicken format)
        (chicken string)
        (chicken io)
        (chicken irregex)
        srfi-69)

(define container-re '(: bos (+ (or alpha white)) (look-ahead "bags contain")))
(define containee-re '(+ num (+ (or alpha white)) (look-ahead (: (or "bag" "bags") (? ",")))))
(define number-re '(: num))

(define (get-container line)
  (string-chomp (car (irregex-extract container-re line)) " "))

(define (get-containees line)
  (let* ((strings (irregex-extract containee-re line)))
    (map (lambda (nc) 
           (let ((sstring (string-split nc)))
             (cons (string-intersperse (cdr sstring)) (string->number (car sstring)))))
         strings)))

;build a containee -> ((container,number)...) relation
;for part1 cause i didn't want to iterate over the whole set a second time. YES I WAS A MORON.
(define (parseline l graph)
  (let ((container (get-container l))
        (containees (get-containees l)))
    (map (lambda (c)
           (hash-table-update! graph 
                               (car c) 
                               (lambda (en) (append en (list (cons container (cdr c)))))
                               (lambda () '())))
         containees)
    graph))

(define (find-all-parents key graph)
    (let loop ((frontier key)
               (seen '()))
      (if (null? frontier)
          seen
        (let* ((x (car frontier))
               (xs (cdr frontier))
               (par (hash-table-ref/default graph (car x) '())))
          (if (null? par)
              (loop (append xs) (append seen (list x)))
              (loop (append par xs) (append seen (list x))))))))



;build the normal thing for part2 fml. ;p
(define (parseline2 l graph)
  (let ((container (get-container l))
        (containees (get-containees l)))
    (hash-table-set! graph container containees)
    graph))

(define (find-number-children key graph)
  (let ((children (hash-table-ref/default graph key '())))
    (if (null? children)
       0
       (+ (foldr + 0 (map cdr children))
          (foldr (lambda (x acc) (+ acc (* (cdr x) (find-number-children (car x) graph)))) 0 children)))))
 

(define (buildgraph linefunc)
   (call-with-input-file "inputs/input" 
              (lambda (p) 
                (let ((alll (read-lines p))) 
                  (foldr (lambda (x acc)  (linefunc x acc)) (make-hash-table) alll)))))

(define res (buildgraph parseline))
(define pars (find-all-parents (list (cons "shiny gold" 1)) res))
(- (length (delete-duplicates pars (lambda (x y) (string=? (car x) (car y))))) 1) ;1 for ourselves that we are in the result list

;part2 
(define res (buildgraph parseline2))
(find-number-children "shiny gold" res)
