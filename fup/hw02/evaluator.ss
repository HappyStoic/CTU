;---------------------------<HELPING FUNCTIONS>--------------------------
;argument state - (<maze> (<coordinate-x> <coordinate-y>) <orientation>)

(define (get-maze-fs state) (car state))
(define (get-orientation-fs state) (car(cddr state)))
(define (get-pair-position-fs state) (cadr state))
(define (get-Xposition-fs state) (car(car(cdr state))))
(define (get-Yposition-fs state) (car(cdr(car(cdr state)))))
(define (get-xth-field x array)
  (if (= x 0) (car array) (get-xth-field (- x 1) (cdr array)))
)

(define (ifSymbolThenList arg)
  (if (symbol? arg) (list arg) arg)
)

(define (asList arg)
  (if (list? (car arg)) arg (list arg))
)

;Increments number on "updateY" position in "li" list
(define (update-single-list li curY updateY action)
  (cond
    ((null? li) '())
    ((= curY updateY) (cons (apply action (list (car li) 1)) (update-single-list (cdr li) (+ curY 1) updateY action)))
    (#t (cons (car li) (update-single-list (cdr li) (+ curY 1) updateY action)))
  )
)
;Update maze - increment mark on standing position and return maze
(define (update-maze maze curX updateX updateY action)
  (cond
    ((null? maze) '())
    ((= curX updateX) (cons (update-single-list (car maze) 0 updateY action) (update-maze (cdr maze) (+ curX 1) updateX updateY action)))
    (#t (cons (car maze) (update-maze (cdr maze) (+ curX 1) updateX updateY action)))
  )
)
;---------------------------</HELPING FUNCTIONS>--------------------------------------------

;---------------------------<USABLE CONDITIONS>---------------------------------------------
(define (north? state)
  (eqv? 'north (get-orientation-fs state))
)

(define (mark? state)
  (define onMyPosition (get-xth-field (get-Xposition-fs state) (get-xth-field (get-Yposition-fs state) (get-maze-fs state))))
  (cond
    ((> onMyPosition 0) #t)
    (#t #f)
  )
)

(define (wall? state)
  (define lookingTo (get-orientation-fs state))
  (cond
    ((north? state) (symbol? (get-xth-field (get-Xposition-fs state) (get-xth-field (- (get-Yposition-fs state) 1) (get-maze-fs state)))))
    ((eqv? 'west lookingTo)
        (symbol? (get-xth-field (- (get-Xposition-fs state) 1) (get-xth-field (get-Yposition-fs state) (get-maze-fs state)))))
    ((eqv? 'east lookingTo)
        (symbol? (get-xth-field (+ (get-Xposition-fs state) 1) (get-xth-field (get-Yposition-fs state) (get-maze-fs state)))))
    ((eqv? 'south lookingTo)
        (symbol? (get-xth-field (get-Xposition-fs state) (get-xth-field (+ (get-Yposition-fs state) 1) (get-maze-fs state)))))
  )
)
;---------------------------</USABLE CONDITIONS>-------------------------------------------

;---------------------------<ROBOT ACTIONS>------------------------------------------------
(define (step state)
    (define lookingTo (get-orientation-fs state))
    (cond
    ((north? state)
        (list (get-maze-fs state) (list (get-Xposition-fs state) (- (get-Yposition-fs state) 1)) lookingTo))
    ((eqv? 'west lookingTo)
        (list (get-maze-fs state) (list (- (get-Xposition-fs state) 1) (get-Yposition-fs state)) lookingTo))
    ((eqv? 'east lookingTo)
        (list (get-maze-fs state) (list (+ (get-Xposition-fs state) 1) (get-Yposition-fs state)) lookingTo))
    ((eqv? 'south lookingTo)
        (list (get-maze-fs state) (list (get-Xposition-fs state) (+ (get-Yposition-fs state) 1)) lookingTo))
    )  
)

(define (turn-left state)
    (define lookingTo (get-orientation-fs state))
    (cond
    ((north? state)
        (list (get-maze-fs state) (get-pair-position-fs state) 'west))
    ((eqv? 'west lookingTo)
        (list (get-maze-fs state) (get-pair-position-fs state) 'south))
    ((eqv? 'east lookingTo)
        (list (get-maze-fs state) (get-pair-position-fs state) 'north))
    ((eqv? 'south lookingTo)
        (list (get-maze-fs state) (get-pair-position-fs state) 'east))
    )
)

(define (get-mark state)
  (list (update-maze (get-maze-fs state) 0 (get-Yposition-fs state) (get-Xposition-fs state) -) (get-pair-position-fs state) (get-orientation-fs state))
)

(define (put-mark state)
  (list (update-maze (get-maze-fs state) 0 (get-Yposition-fs state) (get-Xposition-fs state) +) (get-pair-position-fs state) (get-orientation-fs state))
)
;---------------------------</ROBOT ACTIONS>----------------------------------------------------

;---------------------------<SIMULATOR>---------------------------------------------------------
(define (get-procedure-list program procedure-name)
  (cond
    ((eqv? procedure-name (cadr (car program))) (if (list? (caddr (car program))) (caddr (car program)) (list (caddr (car program)))))
    (#t (get-procedure-list (cdr program) procedure-name))
  )
)

(define (simulate state expr program limit threshold num-steps)
  (if (list? expr) (inSimulate state expr program limit '() threshold num-steps) (inSimulate state (list expr) program limit '() threshold num-steps))
)

(define (inSimulate state expr program limit actions threshold num-steps)
  (cond
    ((or (null? expr) (> num-steps threshold)) (list actions state))

    (#t (let ((todo (car expr)))
          (cond
              ((eqv? 'step todo) (if (wall? state) (list actions state) (inSimulate (step state) (cdr expr) program limit (append actions '(step)) threshold (+ num-steps 1))))
              ((eqv? 'get-mark todo) (if (mark? state) (inSimulate (get-mark state) (cdr expr) program limit (append actions '(get-mark)) threshold (+ num-steps 1)) (list actions state)))
              ((eqv? 'put-mark todo) (inSimulate (put-mark state) (cdr expr) program limit (append actions '(put-mark)) threshold (+ num-steps 1)))
              ((eqv? 'turn-left todo) (inSimulate (turn-left state) (cdr expr) program limit (append actions '(turn-left)) threshold (+ num-steps 1)))
              (#t (goProcedureCall (append (get-procedure-list program (car expr)) '(end)) (cdr expr) limit state program (- limit 1) actions threshold num-steps))
          )
        )
    )
  )
)
(define (goProcedureCall toDoNow toDoLater toLimitLater state program limit actions threshold num-steps)
  (cond
    ((or (< limit 0) (> num-steps threshold)) (list actions state))
    ((null? toDoNow) (inSimulate state toDoLater program toLimitLater actions threshold num-steps))
    ((or (list? (car toDoNow)) (eqv? 'if (car toDoNow)))
        (let ((expr (cadar (asList toDoNow))))
          (if (or (and (eqv? 'north? expr) (north? state)) (and (eqv? 'wall? expr) (wall? state)) (and (eqv? 'mark? expr) (mark? state)))
             (goProcedureCall (append (ifSymbolThenList (caddar (asList toDoNow))) (cdr (cdddar (asList toDoNow))) (cdr (asList toDoNow))) toDoLater toLimitLater state program limit actions threshold num-steps)
             (goProcedureCall (append (ifSymbolThenList (caddr(cdar (asList toDoNow)))) (cdr (cdddar (asList toDoNow))) (cdr (asList toDoNow))) toDoLater toLimitLater state program limit actions threshold num-steps)
          )
        )
    )
    ((eqv? 'end (car toDoNow)) (goProcedureCall (cdr toDoNow) toDoLater toLimitLater state program (+ limit 1) actions threshold num-steps))
    ((eqv? 'step (car toDoNow)) (if (wall? state) (list actions state) (goProcedureCall (cdr toDoNow) toDoLater toLimitLater (step state) program limit (append actions '(step)) threshold (+ num-steps 1))))
    ((eqv? 'get-mark (car toDoNow)) (if (mark? state) (goProcedureCall (cdr toDoNow) toDoLater toLimitLater (get-mark state) program limit (append actions '(get-mark)) threshold (+ num-steps 1)) (list actions state)))
    ((eqv? 'put-mark (car toDoNow)) (goProcedureCall (cdr toDoNow) toDoLater toLimitLater (put-mark state) program limit (append actions '(put-mark)) threshold (+ num-steps 1)))
    ((eqv? 'turn-left  (car toDoNow)) (goProcedureCall (cdr toDoNow) toDoLater toLimitLater (turn-left state) program limit (append actions '(turn-left)) threshold (+ num-steps 1)))
    (#t (goProcedureCall (append (get-procedure-list program (car toDoNow)) '(end) (cdr toDoNow)) toDoLater toLimitLater state program (- limit 1) actions threshold num-steps))
  )
)
;---------------------------</SIMULATOR>--------------------------------------------------------

;---------------------------<HW-02>-------------------------------
;---------------------------<SORT-OUTPUT>-------------------------
(define (bubble-sort li lambda) (bubble-ins (length li) li lambda))

(define (bubble-ins len li lambda)
    (cond ((= len 1) (bubble-up li lambda))   
          (else (bubble-ins (- len 1) (bubble-up li lambda) lambda))))

(define (bubble-up L lambda)
    (if (null? (cdr L))   
        L    
        (if (lambda L)   
            (cons (car L) (bubble-up (cdr L) lambda))   
            (cons (cadr L) (bubble-up (cons (car L) (cddr L)) lambda)))))

(define (sort-values output)
    (let (
        (manhattan-dist-equals? (lambda (L) (= (car (caar L)) (car (caadr L)))))
        (manh-first-less? (lambda (L) (< (car (caar L)) (car (caadr L)))))
        (robot-conf-equals? (lambda (L) (= (cadr (caar L)) (cadr (caadr L)))))
        (robot-conf-first-less? (lambda (L) (< (cadr (caar L)) (cadr (caadr L)))))
        (length-prg-equals? (lambda (L) (= (caddr (caar L)) (caddr (caadr L)))))
        (length-prg-first-less? (lambda (L) (< (caddr (caar L)) (caddr (caadr L)))))
        (num-steps-first-less? (lambda (L) (< (cadddr (caar L)) (cadddr (caadr L)))))
       )
     (bubble-sort output (lambda (L)
                           (cond
                             ((and (manhattan-dist-equals? L)(robot-conf-equals? L)(length-prg-equals? L)) (num-steps-first-less? L))
                             ((and (manhattan-dist-equals? L)(robot-conf-equals? L)) (length-prg-first-less? L))
                             ((manhattan-dist-equals? L)(robot-conf-first-less? L))
                             (#t (manh-first-less? L))
                           )
                         )
     )
  )
)
;---------------------------</SORT-OUTPUT>-------------------------

(define (unfold-list li unfolded)
  (cond
    ((null? li) unfolded)
    ((list? (car li))
        (let ((first (unfold-list (car li) '()))
              (second (unfold-list (cdr li) '())))
              (append unfolded first second)
        )
    )
    (#t (unfold-list (cdr li) (cons (car li) unfolded)))))

 
(define (proc-len len proc)
   (if (null? proc) len (proc-len (if (eqv? (car proc) 'if) len (+ len 1)) (cdr proc)))   
)

(define (length-program len prg)
  (if (null? prg)
      len
      (length-program (+ (+ len 1) (proc-len 0 (unfold-list (if (list? (caddar prg)) (caddar prg) (list(caddar prg))) '()))) (cdr prg)))
)

(define (length-program-delay prg) (delay (length-program 0 prg)))
(define (simulate-delay state expr program limit threshold num-steps) (delay (simulate state expr program limit threshold num-steps))) 


  
(define (evaluate prgs pairs threshold limit)
  (in-evaluate prgs pairs threshold limit '())
)

(define (mylength li) (length li))
(define (getdiff a b) (abs (- a b)))

(define (check-program prg pairs threshold limit output manhattan conf-dist length-arg num-steps)
  (if (null? pairs) (cons (cons  (list manhattan conf-dist length-arg num-steps) (list prg)) output)
    (let ((sim-result (simulate-delay (caar pairs) 'start prg limit (cadddr threshold) num-steps)))
         (let
            (
             (length-prg (if (= length-arg 0) (length-program 0 prg) length-arg))
             (new-manh (delay (+ manhattan (calculate-manhattan (caadar pairs) (caadr (force sim-result))))))
             (new-conf-dist (delay (+ conf-dist (calculate-conf-distance (cdadar pairs) (cdadr (force sim-result))))))
             (new-num-steps (delay (+ num-steps (mylength (car (force sim-result))))))
            )
            (if (or (> length-prg (caddr threshold)) (> (force new-manh) (car threshold)) (> (force new-conf-dist) (cadr threshold)) (> (force new-num-steps) (cadddr threshold)))
                output
                (check-program prg (cdr pairs) threshold limit output (force new-manh) (force new-conf-dist) length-prg (force new-num-steps))
            )
         )
     )
  )
)

(define (calculate-conf-distance desired-position calcul-position)
  (let ((xdiff (abs (- (caar desired-position) (caar calcul-position))))
        (ydiff (abs (- (cadar desired-position) (cadar calcul-position)))))
    (if (eqv? (cadr desired-position) (cadr calcul-position)) (+ xdiff ydiff) (+ xdiff ydiff 1)))
)

(define (calculate-manhattan desired-maze calcul-maze)
  (cond
    ((null? desired-maze) 0)
    ((list? (car desired-maze)) (+ (calculate-manhattan (car desired-maze) (car calcul-maze)) (calculate-manhattan (cdr desired-maze) (cdr calcul-maze))))
    ((number? (car desired-maze)) (+ (getdiff (car desired-maze) (car calcul-maze)) (calculate-manhattan (cdr desired-maze) (cdr calcul-maze))))
    (#t (calculate-manhattan (cdr desired-maze) (cdr calcul-maze)))
  )
)

(define (in-evaluate prgs pairs threshold limit output)
  (if (null? prgs) (sort-values output) (in-evaluate (cdr prgs) pairs threshold limit (check-program (car prgs) pairs threshold limit output 0 0 0 0)))
)
;---------------------------</HW-02>-------------------------------