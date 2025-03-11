;; Retirement Contract
;; Manages the permanent removal of used RECs from circulation

(define-map retired-certificates
  { certificate-id: uint }
  {
    retired-by: principal,
    retirement-date: uint,
    reason: (string-ascii 50)
  }
)

(define-public (retire-certificate (certificate-id uint) (reason (string-ascii 50)))
  (ok (map-set retired-certificates
    { certificate-id: certificate-id }
    {
      retired-by: tx-sender,
      retirement-date: block-height,
      reason: reason
    }
  ))
)

(define-read-only (get-retirement-info (certificate-id uint))
  (map-get? retired-certificates { certificate-id: certificate-id })
)

(define-read-only (is-certificate-retired (certificate-id uint))
  (is-some (get-retirement-info certificate-id))
)

