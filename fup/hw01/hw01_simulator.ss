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
