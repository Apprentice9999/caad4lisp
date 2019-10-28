(in-package :caad4lisp)

;; A real number defining the maximum amount by which expr1 and expr2 can differ
;; and still be considered equal.
(setq Util-Fuzz 1.0e-6)

;;;; debug������ؽ������
(setq @Util-Working
      '("\\" "|" "/" "-"))
;;;; function: Util-Working
(defun Util-Working ()
  "debug the code loading process"
  ; Backspace
  (prompt "\010")
  (setq @Util-Working
        (append
         (cdr @Util-Working)
         (list
          (princ (car @Util-Working)))
         )
        )
  )

;; Parameters:
;; number: int
;; Return
;; bool: True, if the parameter is odd
(defun Util-Odd? (number)
  "check a numer is odd or not?"
  ;; The REM function divides the first number on the second number and returns the reminder.
  (= (rem number 2) 1) 
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;retrieve the Entity Data;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ���Ѿ���õ�entryData��������ݻ����key��ص����ݻ�����
;; parameter:
;; key: element or list, 10 or '(-1 0 10 11)
(defun Util-GetDataByKey (key entData)
    "Get related element or list from entity data by a key"
    (if (atom key)
        (cdr (assoc key eData))
        (mapcar '(lambda (x) (cdr (assoc x eData))) key)
        )
)

;; todo
;; entityData �Ƿ������match����������type����Ϣ
;; match ������typeԪ��Ҳ�����Ƕ��list��ɵ�list
(defun Util-GetEntType (edata match)
    "Check this entity data's type is the matching element or is  included in the matching list "
    (member (Util-GetDataByKey 0 edata) (if (listp match) match (list match)))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; list



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; matrix
