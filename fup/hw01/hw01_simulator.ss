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
  (string=? "north" (symbol->string (get-orientation-fs state)))
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
    ((string=? "west" (symbol->string lookingTo))
        (symbol? (get-xth-field (- (get-Xposition-fs state) 1) (get-xth-field (get-Yposition-fs state) (get-maze-fs state)))))
    ((string=? "east" (symbol->string lookingTo))
        (symbol? (get-xth-field (+ (get-Xposition-fs state) 1) (get-xth-field (get-Yposition-fs state) (get-maze-fs state)))))
    ((string=? "south" (symbol->string lookingTo))
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
    ((string=? "west" (symbol->string lookingTo))
        (list (get-maze-fs state) (list (- (get-Xposition-fs state) 1) (get-Yposition-fs state)) lookingTo))
    ((string=? "east" (symbol->string lookingTo))
        (list (get-maze-fs state) (list (+ (get-Xposition-fs state) 1) (get-Yposition-fs state)) lookingTo))
    ((string=? "south" (symbol->string lookingTo))
        (list (get-maze-fs state) (list (get-Xposition-fs state) (+ (get-Yposition-fs state) 1)) lookingTo))
    )  
)

(define (turn-left state)
    (define lookingTo (get-orientation-fs state))
    (cond
    ((north? state)
        (list (get-maze-fs state) (get-pair-position-fs state) 'west))
    ((string=? "west" (symbol->string lookingTo))
        (list (get-maze-fs state) (get-pair-position-fs state) 'south))
    ((string=? "east" (symbol->string lookingTo))
        (list (get-maze-fs state) (get-pair-position-fs state) 'north))
    ((string=? "south" (symbol->string lookingTo))
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
    ((string=? (symbol->string procedure-name) (symbol->string (cadr (car program)))) (caddr (car program)))
    (#t (get-procedure-list (cdr program) procedure-name))
  )
)

(define (simulate state expr program limit)
  (if (list? expr) (inSimulate state expr program limit '()) (inSimulate state (list expr) program limit '()))
)

(define (inSimulate state expr program limit actions)
  (cond
    ((null? expr) (list actions state))

    (#t (let ((todo (car expr)))(cond
                                    ((string=? "step" (symbol->string todo))
                                     (if (wall? state) (list actions state) (inSimulate (step state) (cdr expr) program limit (append actions '(step)))))
                                    ((string=? "get-mark" (symbol->string todo))
                                     (if (mark? state) (inSimulate (get-mark state) (cdr expr) program limit (append actions '(get-mark))) (list actions state)))
                                    ((string=? "put-mark" (symbol->string todo))
                                     (inSimulate (put-mark state) (cdr expr) program limit (append actions '(put-mark))))
                                    ((string=? "turn-left" (symbol->string todo))
                                     (inSimulate (turn-left state) (cdr expr) program limit (append actions '(turn-left))))
                                    (#t (goProcedureCall (append (get-procedure-list program (car expr)) '(end)) (cdr expr) limit state program (- limit 1) actions))
                                 )
         )
     )
   )
)
(define (goProcedureCall toDoNow toDoLater toLimitLater state program limit actions)
  (cond
    ((< limit 0) (list actions state))
    ((null? toDoNow) (inSimulate state toDoLater program toLimitLater actions))
    ((or (list? (car toDoNow)) (string=? "if" (symbol->string (car toDoNow)))) ;(string=? "if" (symbol->string (car toDoNow)))
        (cond
           ((string=? "north?" (symbol->string (cadr (car (asList toDoNow)))))
               (if (north? state)
                   (goProcedureCall (append (ifSymbolThenList (caddr (car (asList toDoNow)))) (cdr (cdr (cdr (cdr (car (asList toDoNow)))))) (cdr (asList toDoNow))) toDoLater toLimitLater state program limit actions)
                   (goProcedureCall (append (ifSymbolThenList (caddr(cdr (car (asList toDoNow))))) (cdr (cdr (cdr (cdr (car (asList toDoNow)))))) (cdr (asList toDoNow))) toDoLater toLimitLater state program limit actions)
               )
           )
           ((string=? "wall?" (symbol->string(cadr (car (asList toDoNow)))))
               (if (wall? state) 
                   (goProcedureCall (append (ifSymbolThenList (caddr (car (asList toDoNow)))) (cdr (cdr (cdr (cdr (car (asList toDoNow)))))) (cdr (asList toDoNow))) toDoLater toLimitLater state program limit actions)
                   (goProcedureCall (append (ifSymbolThenList (caddr(cdr (car (asList toDoNow))))) (cdr (cdr (cdr (cdr (car (asList toDoNow)))))) (cdr (asList toDoNow))) toDoLater toLimitLater state program limit actions)
               )
           )
           ((string=? "mark?" (symbol->string(cadr (car (asList toDoNow)))))
               (if (mark? state) 
                   (goProcedureCall (append (ifSymbolThenList (caddr (car (asList toDoNow)))) (cdr (cdr (cdr (cdr (car (asList toDoNow)))))) (cdr (asList toDoNow))) toDoLater toLimitLater state program limit actions)
                   (goProcedureCall (append (ifSymbolThenList (caddr(cdr (car (asList toDoNow))))) (cdr (cdr (cdr (cdr (car (asList toDoNow)))))) (cdr (asList toDoNow))) toDoLater toLimitLater state program limit actions)
               )
           )
           (#t (quote "error 420"))
        )
    )
    ((string=? "end" (symbol->string (car toDoNow))) (goProcedureCall (cdr toDoNow) toDoLater toLimitLater state program (+ limit 1) actions))
    ((string=? "step" (symbol->string (car toDoNow)))
     (if (wall? state) (list actions state) (goProcedureCall (cdr toDoNow) toDoLater toLimitLater (step state) program limit (append actions '(step)))))
    ((string=? "get-mark" (symbol->string (car toDoNow)))
     (if (mark? state) (goProcedureCall (cdr toDoNow) toDoLater toLimitLater (get-mark state) program limit (append actions '(get-mark))) (list actions state)))
    ((string=? "put-mark" (symbol->string (car toDoNow)))
     (goProcedureCall (cdr toDoNow) toDoLater toLimitLater (put-mark state) program limit (append actions '(put-mark))))
    ((string=? "turn-left" (symbol->string (car toDoNow)))
     (goProcedureCall (cdr toDoNow) toDoLater toLimitLater (turn-left state) program limit (append actions '(turn-left))))
    (#t (goProcedureCall (append (get-procedure-list program (car toDoNow)) '(end) (cdr toDoNow)) toDoLater toLimitLater state program (- limit 1) actions))
  )
)
;---------------------------</SIMULATOR>--------------------------------------------------------