;; REC Issuance Contract
;; Creates certificates for verified renewable energy production

(define-map certificates
  { certificate-id: uint }
  {
    producer: principal,
    energy-amount: uint,
    energy-type: (string-ascii 20),
    issuance-date: uint,
    expiration-date: uint,
    status: (string-ascii 10)
  }
)

(define-data-var last-certificate-id uint u0)

(define-read-only (get-certificate (certificate-id uint))
  (map-get? certificates { certificate-id: certificate-id })
)

(define-public (issue-certificate (energy-amount uint) (energy-type (string-ascii 20)) (validity-period uint))
  (let
    (
      (new-certificate-id (+ (var-get last-certificate-id) u1))
    )
    (var-set last-certificate-id new-certificate-id)
    (ok (map-set certificates
      { certificate-id: new-certificate-id }
      {
        producer: tx-sender,
        energy-amount: energy-amount,
        energy-type: energy-type,
        issuance-date: block-height,
        expiration-date: (+ block-height validity-period),
        status: "active"
      }
    ))
  )
)

(define-read-only (is-certificate-valid (certificate-id uint))
  (match (get-certificate certificate-id)
    certificate (and
      (is-eq (get status certificate) "active")
      (<= block-height (get expiration-date certificate))
    )
    false
  )
)

