(import (chicken string))
(import (chicken format))
(import (chicken io))
(import comparse)
(import srfi-14)

;comparse helpers
(define (constrained parser pred)
  (bind parser
        (lambda (val)
          (if (pred val)
              (result val)
              fail))))

(define (as-number parser)
  (bind (as-string parser)
        (lambda (s)
          (result (string->number s)))))

(define digit
  (in char-set:digit))

(define smallhex
  (in (char-set-difference char-set:hex-digit char-set:upper-case)))

(define (digits n)
  (as-number (repeated digit n)))

(define byear
  (constrained (digits 4)
               (lambda (v)
                 (and (>= v 1920)
                      (<= v 2002)))))
(define iyear
  (constrained (digits 4)
               (lambda (v)
                 (and (>= v 2010)
                      (<= v 2020)))))
 (define eyear
   (constrained (digits 4)
                (lambda (v)
                  (and (>= v 2020)
                       (<= v 2030)))))

(define haircl
  (sequence (in #\#) smallhex))

(define eyecl
  (any-of (char-seq "amb")
          (char-seq "blu")
          (char-seq "brn")
          (char-seq "gry")
          (char-seq "grn")
          (char-seq "hzl")
          (char-seq "oth")))

(define hgt-in
  (constrained (sequence (digits 2)
                         (char-seq "in"))
               (lambda (v)
                 (and (>= (car v) 59)
                      (<= (car v) 76)))))
 
(define hgt-cm
  (constrained (sequence (digits 3)
                         (char-seq "cm"))
               (lambda (v)
                 (and (>= (car v) 150)
                      (<= (car v) 193)))))                

(define height
  (any-of hgt-cm hgt-in))

(define passid
  (digits 9))

(define val-ecl
  (sequence (in #\#) smallhex))

(define (valid-byr? byr) (parse byear byr))
(define (valid-iyr? iyr) (parse iyear iyr))
(define (valid-eyr? eyr) (parse eyear eyr))
(define (valid-hgt? hgt) (parse height hgt))
(define (valid-hcl? hcl) (parse haircl hcl))
(define (valid-ecl? ecl) (parse eyecl ecl))
(define (valid-pid? pid) (parse passid pid))
(define (valid-cid? cid) #t)
 

(define (make-passport)
  (let* ((byr '())
         (iyr '())
         (eyr '())
         (hgt '())
         (hcl '())
         (ecl '())
         (pid '())
         (cid '())
         (rem 7)
         (valid? (lambda () (and (= rem 0)
                                 (valid-byr? byr)
                                 (valid-iyr? iyr)
                                 (valid-eyr? eyr)
                                 (valid-hgt? hgt)
                                 (valid-hcl? hcl)
                                 (valid-ecl? ecl)
                                 (valid-pid? pid)
                                 (valid-cid? cid)))))
    (lambda (d)
      (cond 
        ((string=? d "byr") (lambda (v)
                 (set! byr v)
                 (set! rem (- rem 1))))
        ((string=? d "iyr") (lambda (v)
                 (set! iyr v)
                 (set! rem (- rem 1))))
        ((string=? d "eyr") (lambda (v)
                 (set! eyr v)
                 (set! rem (- rem 1))))
        ((string=? d "hgt") (lambda (v)
                 (set! hgt v)
                 (set! rem (- rem 1))))
        ((string=? d "hcl") (lambda (v)
                 (set! hcl v)
                 (set! rem (- rem 1))))
        ((string=? d "ecl") (lambda (v)
                 (set! ecl v)
                 (set! rem (- rem 1))))
        ((string=? d "pid") (lambda (v)
                 (set! pid v)
                 (set! rem (- rem 1))))
        ((string=? d "cid") (lambda (v)
                 (set! cid v)))
        ((string=? d "valid?") (valid?))
        ((string=? d "print")  (format #t "passport-ID:~A birth-year:~A  issue-year:~A exp-year:~A height:~A hair:~A eyes:~A country-ID:~A valid?:~A(~A remaining)~%"
                          pid byr iyr eyr hgt hcl ecl cid (valid?) rem))
        (else     (error "unknown dispatch on passport"))))))
    

(define (passfield-name pf) (car pf))

(define (count-passports lines)
  (foldr (lambda (x acc)
           (if (string=? x "")
               (+ 1 acc)
               acc))
         0 
         lines))

(define (make-passports lines)
  (let ((newpassports '())
        (currpassport (make-passport)))
    (foldr (lambda (line acc)
             (cond ((string=? line "") (set! newpassports (append newpassports (list currpassport)))
                                       (set! currpassport (make-passport)))
                   (else  (let* ((fields (string-split line))
                                 (fvals (map (lambda (sfv) (string-split sfv ":")) fields)))
                            (format #t "i read field vals ~A~%" fvals)
                            (map (lambda (fv) 
                                   ((currpassport (car fv)) (cadr fv))) 
                                 fvals)))))
           '()
           lines)
    newpassports))

(define results 
  (call-with-input-file "inputs/input"
    (lambda (p)
      (let* ((alines (read-lines p))
             (totpass (count-passports alines))
             (newpasses (make-passports alines)))
        (map (lambda (ps) (ps "valid?")) newpasses)))))

;number of valid passports
(format #t "number of passports:~A . valid passports: ~A" (length results)
  (foldr (lambda (v acc) 
           (if (eq? v #t) 
               (+ 1 acc) 
               acc)) 
         0 
         results))
