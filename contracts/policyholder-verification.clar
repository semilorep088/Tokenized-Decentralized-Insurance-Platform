;; Policyholder Verification Contract
;; Validates insured parties and manages policyholder registration

(define-data-var admin principal tx-sender)

;; Data map to store policyholder information
(define-map policyholders principal
  {
    verified: bool,
    registration-time: uint,
    risk-category: uint
  }
)

;; Public function to register a new policyholder
(define-public (register-policyholder (risk-category uint))
  (let ((caller tx-sender))
    (asserts! (is-none (map-get? policyholders caller)) (err u1)) ;; Error if already registered
    (ok (map-set policyholders caller
      {
        verified: false,
        registration-time: block-height,
        risk-category: risk-category
      }
    ))
  )
)

;; Admin function to verify a policyholder
(define-public (verify-policyholder (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u2)) ;; Only admin can verify
    (asserts! (is-some (map-get? policyholders address)) (err u3)) ;; Must be registered
    (ok (map-set policyholders address
      (merge (unwrap-panic (map-get? policyholders address)) {verified: true})
    ))
  )
)

;; Read-only function to check if an address is a verified policyholder
(define-read-only (is-verified-policyholder (address principal))
  (default-to false (get verified (map-get? policyholders address)))
)

;; Read-only function to get policyholder details
(define-read-only (get-policyholder-details (address principal))
  (map-get? policyholders address)
)

;; Function to update admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u4)) ;; Only current admin can change
    (ok (var-set admin new-admin))
  )
)
