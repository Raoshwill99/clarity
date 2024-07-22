
;; title: showroom
;; version: 1.0
;; summary: A simple voting system to add candidates, cast votes, and determine the winner.
;; description: This smart contract allows adding candidates, casting votes, retrieving the total number of votes, and determining the winner based on the highest number of votes.

(define-data-var candidates (map u256 (tuple (name string) (votes u256))))

(define-read-only (get-candidates)
  (ok candidates))

(define-read-only (get-votes (candidate u256))
  (match (map-get candidates candidate)
    ((ok (tuple name votes)) votes)
    (err "Candidate not found")))

(define-private (add-candidate (candidate u256) (name string))
  (if (map-contains? candidates candidate)
    (err "Candidate already exists")
    (begin
      (map-set candidates candidate (tuple name 0))
      (ok "Candidate added"))))

(define-private (cast-vote (candidate u256))
  (match (map-get candidates candidate)
    ((ok (tuple name votes))
      (map-set candidates candidate (tuple name (+ votes 1)))
      (ok "Vote cast"))
    (err "Candidate not found")))

(define-read-only (get-winner)
  (let ((winner (reduce-map candidates (tuple 0 0) (lambda (k v acc)
                                                    (if (> (tuple-get v 1) (tuple-get acc 1))
                                                      v
                                                      acc)))))
    (ok (tuple-get winner 0))))

(define-read-only (get-total-votes)
  (let ((total (reduce-map candidates 0 (lambda (k v acc)
                                          (+ acc (tuple-get v 1))))))
    (ok total)))
