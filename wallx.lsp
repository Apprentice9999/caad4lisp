;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ��������ǽ���ཻ֮�����(wall-x)
;; issue: ����������autocad 2006 ��ִ�д���, ɾ�����Ŀ��Ա�ִ��
;;
;; Util.lsp
;; Util-Working: ���н���debugger
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; parameter: 
;; >90:    90 degree angle
(defun c:wallx (/ >90 dists edata  i l0
                neatx1 perps pt0 pt1 pt2 pt3 pt4 pt5 pt6
                slope sort ss ssfunc  wall1 wall2 walls
                )

  (setq clayer nil)
  (princ "\nLoading -")
  
  (Util-Working)
  ;;;;;;;;;;;;;;;;;;; 
  ;;�Ͽ�����  start
  ;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; dist1Ϊpt0��wall1�����ߵľ���
  ;; ((125.34581575 2) (175.34581575 1)) ;(car dists)  (wall1line2-dist,wall1line1-dist)
  ;;
  ;; dist2Ϊpt0��wall2�����ߵľ���
  ;; ((72.25407628  2) (122.25407628 1))  ;(cadr dists) (wall2line2-dist,wall2line1-dist)
  (defun neatx1 (dist1 dist2)
    (cond
      ((cdr dist1)
       (Util-Working)
       (neatx2
        ;; 1st wall - line 1
        (nth (cadar dist1) wall1)
        ;; 1st wall - line 2
        (nth (cadr (last dist1)) wall1)
        ;; 2nd wall - line 1
        (nth (cadar dist2) wall2)
        ;; 2nd wall - line 2
        (nth (cadr (last dist2)) wall2)
        )
       )
      (T (princ "\rComplete."))
      )
    )
  ;; a1: walla-line1
  ;; a2: walla-line2
  ;; b1: wallb-line1
  ;; b2: wallb-line2
  (defun neatx2 (a1 a2 b1 b2)
    (mapcar
     '(lambda (wallx l1 l2)
       (Util-Working)
       (setq
        pt1 (cadr  l1)
        pt2 (caddr l1)
        pt3 (cadr  l2)
        pt4 (caddr l2)
	    )
       (foreach l0 wallx
        (setq
         pt5 (cadr  l0)
         pt6 (caddr l0)
         )
        "�Ͽ�����"
         (if (= Conf-AutoCAD-Version "2015+")
            (command-s ".BREAK" (car l0) "F" (inters pt5 pt6 pt1 pt2) (inters pt5 pt6 pt3 pt4))
            (command ".BREAK" (car l0)  (inters pt5 pt6 pt1 pt2) (inters pt5 pt6 pt3 pt4))
            )
        )



               
       ) ;_ lambda
     
     (list (list a1 a2) (list b1 b2)) 
     (list b1 a1) 
     (list b2 a2)
     ) ;_ carmap
    ) ;_ defun
  ;;;;;;;;;;;;;;;;
  ;;�Ͽ�����  end
  ;;;;;;;;;;;;;;;;

  
  (Util-Working)
  ;; befor sorting: ((121.02304632 1) (171.02304632 2))
  ;; after sorting: ((121.02304632 1) (171.02304632 2))
  ;; befor sorting: ((102.55026166 1) (52.55026166 2))
  ;; after sorting: ((52.55026166 2) (102.55026166 1))
  ;; ���������е�һ����ֵ��С�������������
  (defun sort (l)
    (if (< (caar l) (caar (cdr l)) )
        l  
        (reverse l)
    )
  )

  (Util-Working)
  ;; �Կ�ѡ��4��ֱ��(ss)��ÿһ��ֱ�߶�ͨ��������(ename)���غ���func
  (defun ssfunc  (ss func / i ename)
    (setq i -1)
    (while (setq ename (ssname ss (setq i (1+ i))))
      (apply func nil)
      )
    )

  
  ;;---------------
  ;; Main Function
  ;;---------------
  (setq >90 (/ pi 2))
  ;; CmdEcho:  Controls whether prompts and input are echoed during the AutoLISP command function.
  (setvar "CmdEcho" 0)
  ;; Blipmode is an obsolete AutoCAD function that, in earlier versions of the software,
  ;; left a mark in your drawing on points that you specified.
  ;; The marks are visual references and do not appear in printouts of the drawing.
  ;; Though Blipmode is obsolete,
  ;; it is still an available function in AutoCAD if you turn it on or
  ;; import a project saved using an older version of the software that had Blipmode enabled.
  ;; To remove the blips, you need to disable the Blipmode function in AutoCAD.
  (setvar "BlipMode" 0)
  (princ "\rLoaded. ")

  ;;------------------------------------
  ;; ����ѡ4lines start  ���ҳ�ʼpt0 pt1
  ;;-------------------------------------
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
        ;; ͨ�������ѡ����
        ss (ssget "C" pt0 pt1)
        )
       )
      (T (princ "\rGot4Lines."))
      )
    (princ "\n------4lines--------------\n")
    (princ ss)
    (command ".UNDO" "Group")
    ;;-----------------------------------
    ;; ����ѡ4lines end
    ;;------------------------------------
    
    (ssfunc ss
            '(lambda ()
              (Util-Working)
              ;; ͨ��ename��ȡֱ�ߵ��������edata
              (setq edata (entget ename))
              ;; (princ "\n------raw data------\n")
              ;; (princ edata)
              
              ;; ����ǡ�LINE�������У� �����������һ��Ԫ��
              ;; ���Ϊwalls����(wall1 wall2)
              ;; wall(slope edata1 edate2)
              (if (= (Util-GetDataByKey 0 edata) "LINE")
                  (setq
                   ;; Get relevant groups
                   edata (Util-GetDataByKey '(-1 10 11) edata)
                   slope (Geom2D-GetSlope (cadr edata) (caddr edata))
                   walls
                   ;; Does this slope already exist in walls list
                   (if (setq temp (assoc slope walls))
                       ;; Yes, add new line info to assoc group
                       (subst (append temp (list edata)) temp walls)
                       ;; Nope, add new assoc group w/line info
                       (cons (cons slope (list edata)) walls)
                       )
                   )
                  )
              )
            )
   
    ;; walls list 
    ;;   (
    ;;       (  1.2551  ;wall1-slope
    ;;           (<EName:  000060000051eb80> ;wall1-line1
    ;;                     (-122.06991376 -34.25186944 0.0) (-46.76141103 -128.77172492 0.0) 
    ;;           ) 
    ;;           (<EName:  000060000051efd0> ;wall1-line2
    ;;                     (-75.50710189 -12.4545372 0.0) (-7.65601242 -97.61457806 0.0)
    ;;           )
    ;;        ) 
    ;;        (  0.4681 ;wall2-slope 
    ;;           (<EName:  000060000051ee50>  ;wall2-line1
    ;;                     (-107.38380958 -112.7592744 0.0) (249.25108723 54.19132471 0.0)
    ;;           ) 
    ;;           (<EName:  000060000051ec70> ;wall2-line2
    ;;                     (-139.42098818 -72.54934615 0.0) (217.21390863 94.40125295 0.0)
    ;;            )
    ;;        )
    ;;    )
    (princ "\n------walls-------------------\n")
    (princ walls)
    (princ "\n------------------------------\n")

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
       ;;------------------------------------
       ;; Create List of Perpendiculars(��ֱ��)
       ;; ��ȡpt0��ֱ��walls�Ĵ�ֱ�㣨wall1-ps,wall2-ps��
       ;;------------------------------------
       (setq perps
             (mapcar
              '(lambda (x)
                (Util-Working)
                (mapcar
                 '(lambda (y)
                   (Util-Working)
                   (Geom-PerpPoint pt0 (cadr y) (caddr y))
                   )
                 (cdr x)
                 )
                )
              walls
              )
             )
       ;;--------------------------
       ;; Create List of Distances
       ;; ��ȡpt0��ֱ��walls�Ĵ�ֱ���벢��ÿ��ǽ��ǽ�߽��б�ţ�wall1-dist,wall2-dist��
       ;; wall1-dist(wall1-dist1, wall1-dist2)
       ;; wall1-dist(wall1-dist1, wall1-dist2)
       ;;--------------------------
       (setq dists
             (mapcar
              '(lambda (x)
                (Util-Working)
                (setq i 0)
                (mapcar
                 '(lambda (y)
                   (Util-Working)
                   ;; Create list of distances (with pointers to WALLS)
                   (list
                    ;; Compute distances
                    (distance pt0 y)
                    ;; Key
                    (setq i (1+ i))
                    )
                   )
                 x
                 )
                )
              ;; List of perpendicular points
              perps
              )
             )

       ;; Sort distance index
       ;; befor sorting:
       ;; (((121.02304632 1) (171.02304632 2)) ((102.55026166 1) (52.55026166 2)))
       ;; after sorting:
       ;; (((121.02304632 1) (171.02304632 2)) ((52.55026166 2) (102.55026166 1)))
       (setq dists (mapcar 'sort dists))
       (setq 
         wall1 (car walls) 
         wall2 (cadr walls)
       )
       
       ;;---dists: ��walls��ÿ��line�����ɽ���Զ������------
       ;;(
       ;;  ((125.34581575 2) (175.34581575 1))  ;(car dists)  (wall1line2-dist,wall1line1-dist)
       ;;  ((72.25407628  2) (122.25407628 1))  ;(cadr dists) (wall2line2-dist,wall2line1-dist)
       ;;)
       ;; ----wall1-----
       ;;(1.2551 
       ;; (<EName:  000060000051eb80> (-122.06991376 -34.25186944 0.0) (-46.76141103 -128.77172492 0.0))  ;wall1line1
       ;; (<EName:  000060000051efd0> (-75.50710189 -12.4545372 0.0) (-7.65601242 -97.61457806 0.0)))     ;wall1line2
       ;;----wall2-----
       ;;(0.4681 
       ;; (<EName:  000060000051ee50> (-107.38380958 -112.7592744 0.0) (249.25108723 54.19132471 0.0))    ;wall2line1
       ;; (<EName:  000060000051ec70> (-139.42098818 -72.54934615 0.0) (217.21390863 94.40125295 0.0)))   ;wall2line2
       (princ "\n------dists-------------------\n")
       (princ dists)
       (princ "\n------wall1-------------------\n")
       (princ wall1)
       (princ "\n------wall2-------------------\n")
       (princ wall2)
       (princ "\n------------------------------\n")
       
       ;; Clean intersections
       (neatx1 (car dists) (cadr dists))
       )
      )
    (command ".UNDO" "End")
    )
  
  ;;----------------------------
  ;; Restore enviroment, memory
  ;;----------------------------
  (princ)
  )

(princ "\n  WALLX loaded.")
(princ)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; End Of File
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
