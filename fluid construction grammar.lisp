;; (ql:quickload :fcg)

(in-package :fcg)

(activate-monitor trace-fcg)


;; Assignment 3 construction grammar
;; Jasper Busschers 0513534
 

(def-fcg-constructions nlp-exercise

; We start by defining the literals, these are not given any meaning or reference.
; The set containing all literals is called article and contains:
; the
  (def-fcg-cxn the-cxn
               ((?the-unit
                 (syn-cat (lex-class article))
                 (referent ?t))
                <-
                (?the-unit
                 --
                 (HASH form ((string ?the-unit "the"))))))

  
; Then we define the set of objects containing:
;window  (window w-ref)
  (def-fcg-cxn window-cxn
               ((?window-unit
                 (syn-cat (lex-class object))
                 (referent ?w)
                 (meaning ((window ?w))))
                <-
                (?window-unit
                 --
                 (HASH form ((string ?window-unit "window"))))))
; Then we define the set of persons containing the following entries:
;spy  (spy s-ref)
  (def-fcg-cxn spy-cxn
               ((?spy-unit
                 (syn-cat (lex-class person))
                 (referent ?s)
                 (meaning ((spy ?s))))
                <-
                (?spy-unit

                 --
                 (HASH form ((string ?spy-unit "spy"))))))
;president (president p-ref)
  (def-fcg-cxn president-cxn
               ((?president-unit
                 (syn-cat (lex-class person))
                 (referent ?p)
                 (meaning ((president ?p))))
                <-
                (?president-unit
                 --
                 (HASH form ((string ?president-unit "president"))))))

;The set of adjectives containing the following element
 ;attractive (attractive a-ref)
   (def-fcg-cxn attractive-cxn
               ((?attractive-unit
                 (syn-cat (lex-class adj))
                 (referent ?a)
                 (meaning ((attractive ?a))))
                <-
                (?attractive-unit
                 --
                 (HASH form ((string ?attractive-unit "attractive"))))))

;And finally the set of verbs containing the following entries
 ;broke (break b-ref)
   (def-fcg-cxn broke-cxn
               ((?broke-unit
                 (syn-cat (lex-class verb))
                 (referent ?b)
                 (meaning ((break ?b))))
                <-
                (?broke-unit
                 --
                 (HASH form ((string ?broke-unit "broke"))))))


;blackmailed (blackmail b-ref)
   (def-fcg-cxn blackmailed-cxn
               ((?blackmailed-unit
                 (syn-cat (lex-class verb))
                 (referent ?b)
                 (meaning ((blackmail ?b))))
                <-
                (?blackmailed-unit
                 --
                 (HASH form ((string ?blackmailed-unit "blackmailed"))))))


 ; Now we will evaluate 2 different kinds of noun phrases, we call these nuon-phrase-person (NPP) and nuon-phrase-object (NPO).
 ; These will evaluate the case when an literal is combined with either a person or orbject   
; the person (NPP)
  (def-fcg-cxn noun-phrase-person-cxn
               ((?npp-unit
                 (subunits (?art-unit ?person-unit))
                 (syn-cat (phrase-type npp))
                 (referent ?ref)
                 (bd (leftmost-unit ?art-unit)
                     (rightmost-unit ?p)))
                <-
                (?art-unit
                 --
                 (syn-cat (lex-class article)))
                (?person-unit
                 --
                 (syn-cat (lex-class person))
                 (referent ?ref))
                (?npp-unit
                 --
                 (HASH form ((meets ?art-unit ?person-unit))))))

  ;the object  (NPO)
   (def-fcg-cxn noun-phrase-object-cxn
               ((?npo-unit
                 (subunits (?art-unit ?object-unit))
                 (syn-cat (phrase-type npo))
                 (referent ?ref)
                 (bd (leftmost-unit ?art-unit)
                     (rightmost-unit ?w )))
                <-
                (?art-unit
                 --
                 (syn-cat (lex-class article)))
                (?object-unit
                 --
                 (syn-cat (lex-class object))
                 (referent ?ref))
                (?npo-unit
                 --
                 (HASH form ((meets ?art-unit ?object-unit))))))


   ;When the literal is followed by an adjective and then a person, we also consider this a NPP.
   ;However we include the adjective as extra meaning. 
   ;the attractive person

   (def-fcg-cxn noun-phrase-adj-person-cxn
               ((?npap-unit
                 (subunits (?art-unit ?adj-unit ?person-unit))
                 (syn-cat (phrase-type npp))
                 (referent ?ref)
                  (meaning ((:arg0 ?ref2 ?ref)))
                 (bd (leftmost-unit ?art-unit)
                     (rightmost-unit ?person-unit)))
                <-
                (?art-unit
                 --
                 (syn-cat (lex-class article)))
                (?adj-unit
                 --
                 (referent ?ref2)
                 (syn-cat (lex-class adj)))
                (?person-unit
                 --
                 (referent ?ref)
                 (syn-cat (lex-class person)))
                (?npap-unit
                 --
                 (HASH form ((meets ?art-unit ?adj-unit)
                             (meets ?adj-unit ?person-unit))))))

;Here we define the rule for when an NPO is followed by a verb. In these sentences the object performs some action.    
;NPO/VERB

      (def-fcg-cxn object-verb-cxn
                (
                 (?ov-unit
                 (subunits (?object-unit  ?verb-unit))
                  (meaning ((:arg0 ?win ?rf-v)))
                 )
                 <-
                 
                (?object-unit
                 --
                 (referent ?win)
                 (syn-cat  (lex-class object)))
                
                (?verb-unit
                 --
                 (referent ?rf-v)
                 (syn-cat (lex-class verb)))
                  (?ov-unit
                 --
                 (HASH form (
                             (meets ?object-unit ?verb-unit))))))
     
;Now we will implement support for when a person performs some action on either a person or an object.
;These structures start with NPP and a verb and end with either another NPP or an NPO
;NPP/VERB/NPP
   (def-fcg-cxn person-verb-person-cxn
               ((?pvp-unit
                 (subunits (?person1-unit ?verb ?person2-unit))
                 (meaning ((:arg0 ?ev ?rf1)
                           (:arg1 ?ev ?rf2)))
                 (syn-cat (phrase-type pvp)))
                <-
                (?person1-unit
                 --
                 (referent ?rf1)
                 (syn-cat (phrase-type npp))
                 (bd (rightmost-unit ?person1)))
                (?verb
                 --
                 (referent ?ev)
                 (syn-cat (lex-class verb)))
                (?person2-unit
                 --
                 (referent ?rf2)
                 (bd (rightmost-unit ?person2))
                 (syn-cat (phrase-type npp)))
                (?pvp-unit
                 --
                 (HASH form ((meets ?person1 ?verb)
                             (meets ?verb ?person2))))))
;NPP/VERB/NPO
   (def-fcg-cxn person-verb-object-cxn
               ((?pvo-unit
                 (subunits (?person1-unit ?verb ?object2-unit))
                 (meaning ((:arg0 ?ev ?p)
                           (:arg1 ?ev ?w)))
                 (syn-cat (phrase-type pvo)))
                <-
                (?person1-unit
                 --
                 (referent ?p)
                 (syn-cat (phrase-type npp))
                 (bd (rightmost-unit ?person1)))
                (?verb
                 --
                 (referent ?ev)
                 (syn-cat (lex-class verb)))
                (?object2-unit
                 --
                 (referent ?w)
                 (bd (rightmost-unit ?object2))
                 (syn-cat (phrase-type npo)))
                (?pvo-unit
                 --
                 (HASH form ((meets ?person1 ?verb)
                             (meets ?verb ?object2))))))
)


(comprehend "the spy broke the window")
(comprehend "the window broke")
(comprehend "the attractive spy blackmailed the president")
