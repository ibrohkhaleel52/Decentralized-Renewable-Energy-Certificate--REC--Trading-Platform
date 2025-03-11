;; Trading Contract
;; Facilitates buying and selling of RECs

(define-map orders
  { order-id: uint }
  {
    seller: principal,
    certificate-id: uint,
    price: uint,
    status: (string-ascii 10)
  }
)

(define-data-var last-order-id uint u0)

(define-read-only (get-order (order-id uint))
  (map-get? orders { order-id: order-id })
)

(define-public (create-sell-order (certificate-id uint) (price uint))
  (let
    (
      (new-order-id (+ (var-get last-order-id) u1))
    )
    (var-set last-order-id new-order-id)
    (ok (map-set orders
      { order-id: new-order-id }
      {
        seller: tx-sender,
        certificate-id: certificate-id,
        price: price,
        status: "active"
      }
    ))
  )
)

(define-public (fulfill-order (order-id uint))
  (let
    (
      (order (unwrap! (get-order order-id) (err u404)))
    )
    (asserts! (is-eq (get status order) "active") (err u403))
    (try! (stx-transfer? (get price order) tx-sender (get seller order)))
    (ok (map-set orders
      { order-id: order-id }
      (merge order { status: "fulfilled" })
    ))
  )
)

(define-public (cancel-order (order-id uint))
  (let
    (
      (order (unwrap! (get-order order-id) (err u404)))
    )
    (asserts! (is-eq tx-sender (get seller order)) (err u403))
    (asserts! (is-eq (get status order) "active") (err u401))
    (ok (map-set orders
      { order-id: order-id }
      (merge order { status: "cancelled" })
    ))
  )
)

