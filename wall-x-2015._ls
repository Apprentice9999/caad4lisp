;; ��������ǽ���ཻ֮�����(wall-x)
;; inters  ��ȡ�����ߵĽ���
;; polar  Returns the UCS 3D point at a specified angle and distance from a point
;; minusp  Verifies that a number is negative 
;; ssname Returns the object (entity) name of the indexed element of a selection set
;; nth Returns the nth element of a list

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start Of File
(defun c:wall-x (/ >90 @work dists edata etype fuzzy get getslope head i l0
		 merge neatx1 nukenz perp perps pt0 pt1 pt2 pt3 pt4 pt5 pt6
		 slope sort ss ssfunc tail wall1 wall2 walls work
		 )
  (setq clayer nil)
  ;; ���ü����� 
  (princ "\nLoading -")
  (setq @WORK '("\\" "|" "/" "-"))
  (defun WORK ()
    ; Backspace
    (prompt "\010")
    (setq @work (append (cdr @work) (list (princ (car @work)))))
  )

  ;;;;;;;;;;;;;;;; 
  ;;�Ͽ�����  start
  (work)
  (defun NUKENZ (x)
    (cdr (reverse (cdr x)))
  )  
  (work)
  ; dist1Ϊpt0��wall1�����ߵľ���
  ; dist2Ϊpt0��wall2�����ߵľ���
  (defun NEATX1 (dist1 dist2)
    (cond
        ((cdr dist1)
            (work)
            (neatx2
                ; 1st wall - line 1
                (nth (cadar dist1) wall1)
                ; 1st wall - line 2
                (nth (cadr (last dist1)) wall1)
                ; 2nd wall - line 1
                (nth (cadar dist2) wall2)
                ; 2nd wall - line 2
                (nth (cadr (last dist2)) wall2)
            )
            (neatx1 (nukenz dist1) (nukenz dist2))
        )
        (T (princ "\rComplete."))
    )
  )
  (work)
  (defun NEATX2 (a1 a2 b1 b2)
    (mapcar
	'(lambda (x l1 l2)
	    (work)
	    (setq
            pt1 (cadr l1)
            pt2 (caddr l1)
            pt3 (cadr l2)
            pt4 (caddr l2)
	    )
     
	    (foreach
            l0
            x
            (setq
                pt5 (cadr l0)
                pt6 (caddr l0)
            )
            ; �Ͽ�����
            (command-s
                ".BREAK" (car l0)
                (inters pt5 pt6 pt1 pt2)
                (inters pt5 pt6 pt3 pt4)
            )
	    )
	)
	(list (list a1 a2) (list b1 b2))
	(list b1 a1)
	(list b2 a2)
    )
  )
  ;;�Ͽ�����  end
  ;;;;;;;;;;;;;;

  
  (work)
  ;; ͨ��key���ҹ�������
  (defun GET (key alist)
    (if (atom key)
	(cdr (assoc key alist))
	(mapcar '(lambda (x) (cdr (assoc x alist))) key)
	)
  )

  (work)
  ;; �ж�x-y�ľ���ֵ�Ƿ�����С
  (defun FUZZY (x y)
     (< (abs (- x y)) 1.0e-6)
  ) 

  (work)
  ;; ��������������е�һ�����ִ�С��������
  (defun SORT (x)
    (cond
      ((null (cdr x)) x)
      (T
	(merge
	    (sort (head x (1- (length x))))
	    (sort (tail x (1- (length x))))
	)
      )
    )
  )
  (work)
  ;; �ϲ����鲢�Ұ��յ�һ�������һ������������
  (defun MERGE (a b)
    (cond
         ((null a) b)
         ((null b) a)
         ((< (caar a) (caar b))
	    (cons (car a) (merge (cdr a) b))
	 )
	 (t (cons (car b) (merge a (cdr b))))
    )
  )
  (work)
  ;; ��ȡ����l������С��n����
  (defun HEAD (l n)
    (cond
      ((minusp n) nil)
      (t (cons (car l) (head (cdr l) (- n 2))))
      )
   )
  (work)
  ;; ��ȡ����l�����ִ���n����
  (defun TAIL (l n)
    (cond
      ((minusp n) l)
      (t (tail (cdr l) (- n 2)))
      )
   )

  (work)
  ; ��б��  pt1(x1 y1) pt2(x2 y2)   |(y1-2)/(x1-x2)|
  (defun GETSLOPE (pt1 pt2 / x)
    ; Vertical?
    (if (fuzzy (setq x (abs (- (car pt1) (car pt2)))) 0.0)
	; Yes, return NIL
	nil
	; No, compute slope
	(rtos (/ (abs (- (cadr pt1) (cadr pt2))) x) 2 4)
	)
  )
  
  (work)
  ;; edata:���� �Ƿ������match����Ϣ
  (defun ETYPE (edata match)
    (member (get 0 edata) (if (listp match) match (list match)))
  )
  (work)
  (defun SSFUNC (ss func / i ename)
    (setq i -1)
    (while (setq ename (ssname ss (setq i (1+ i))))
      (apply func nil)
      )
   )

  
  (work)
  ;; ��pt0��ͨ��pt1��pt2�Ĵ�ֱ��
  (defun PERP (pt0 pt1 pt2)
    (inters pt1 pt2 pt0 (polar pt0 (+ (angle pt1 pt2) >90) 1.0) nil)
  )

  
  ;---------------
  ; Main Function
  ;---------------
  (setq >90 (/ pi 2))
  ; Stuff Gary will want to fix...
  (setvar "CmdEcho" 0)
  (setvar "BlipMode" 0)
  (princ "\rLoaded. ")

  (while
    (progn
	(initget "Select")
	;; ��ȡ��һ��pt0
	(setq pt0 (getpoint "\nSelect objects/<First corner>: "))
    )
    (setq
	dists nil
	perps nil
	walls nil
    )

    (cond
      ((eq (type pt0) 'LIST)
	(initget 33)
	(setq
	    ;; ��ȡ�ڶ���pt1
	    pt1 (getcorner pt0 "\nOther corner: ")
	    ; ͨ�������ѡ����
	    ss (ssget "C" pt0 pt1)
	    )
      )
      (T
       (while
	   (progn
	     (princ "\nSelect objects: ")
	     (command ".SELECT" "Au" pause)
	     (not (setq ss (ssget "P")))
	     )
	 (print "No objects selected, try again.")
	 )
       (initget 1)
       (setq pt0 (getpoint "\nPoint to outside of wall: "))
       )
      )
    (princ "\nWorking ")
    (command ".UNDO" "Group")

    
    (ssfunc ss
	'(lambda ()
	    (work)
	    (setq edata (entget ename))
	    ; ����ǡ�LINE�������У� �����������һ��Ԫ��
	    ; ���Ϊwalls����(wall1 wall2)
	    ; wall1(slope edata1 edate2)
	    (if (etype edata "LINE")
		(setq
		    ; Get relevant groups
		    edata (get '(-1 10 11) edata)
		    slope (getslope (cadr edata) (caddr edata))
		    walls
		    ; Does this slope already exist in walls list
		    (if (setq temp (assoc slope walls))
			; Yes, add new line info to assoc group
			(subst (append temp (list edata)) temp walls)
			; Nope, add new assoc group w/line info
			(cons (cons slope (list edata)) walls)
		    )
		)
	    )
      )
    )

    (cond
        ((< (length walls) 2)
             (princ "\rerror: Use MEND to join colinear walls.")
        )
        ((> (length walls) 2)
            (princ "\rerror: Only two walls may be cleaned.")
        )
        ((not (apply '= (mapcar 'length walls)))
            (princ "\rerror: Walls have unequal number of lines.")
        )
	(T
	;------------------------------------
	; Create List of Perpendiculars(��ֱ��)
	; ��ȡpt0��ֱ��walls�Ĵ�ֱ�㣨wall1-ps,wall2-ps��
	;------------------------------------
	    (setq perps
		(mapcar
		'(lambda (x)
			(work)
			(mapcar
			    '(lambda (y)
				(work)
				(perp pt0 (cadr y) (caddr y))
			    )
			    (cdr x)
			)
		    )
		    walls
		)
	    )
	    ;--------------------------
	    ; Create List of Distances
	    ; ��ȡpt0��ֱ��walls�Ĵ�ֱ���벢��ÿ��ǽ��ǽ�߽��б�ţ�wall1-dist,wall2-dist��
	    ; wall1-dist(wall1-dist1, wall1-dist2)
	    ;--------------------------
	    (setq dists
            (mapcar
                '(lambda (x)
                (work)
                (setq i 0)
                (mapcar
                    '(lambda (y)
                        (work)
                        ; Create list of distances (with pointers to WALLS)
                    (list
                        ; Compute distances
                        (distance pt0 y)
                        ; Key
                        (setq i (1+ i))
                     )
                    )
                    x
                )
                )
                ; List of perpendicular points
                perps
            )
	    )
	    ; Sort distance index
	    (setq dists (mapcar 'sort dists))
	    (setq wall1 (car walls) wall2 (cadr walls))
	    ; Clean intersections
	    (neatx1 (car dists) (cadr dists))
       )
    )
    (command ".UNDO" "End")
  )

  ;----------------------------
  ; Restore enviroment, memory
  ;----------------------------
  (princ)
)

(princ)
;; End Of File
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
