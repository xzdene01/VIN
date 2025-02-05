using UnityEngine;

public class PlayerController : MonoBehaviour
{
	[Header("Movement Settings")]
	[Tooltip("Base movement speed.")]
	public float moveSpeed = 10f;

	[Tooltip("Multiplier applied when holding the boost key (Left Shift).")]
	public float boostMultiplier = 2f;

	[Header("Rotation Settings")]
	[Tooltip("Rotation sensitivity. Increase for snappier rotation.")]
	public float rotationSpeed = 5f;

	// Internal accumulators for rotation
	private float yaw = 0f;
	private float pitch = 0f;

	void Start()
	{
		// Initialize yaw and pitch based on the current rotation
		yaw = transform.eulerAngles.y;
		pitch = transform.eulerAngles.x;
	}

	void Update()
	{
		// --- Movement (always active) ---
		float forwardInput = Input.GetAxis("Vertical");    // W/S or Up/Down arrows
		float rightInput = Input.GetAxis("Horizontal");    // A/D or Left/Right arrows

		// Use E (up) and Q (down) for vertical movement
		float verticalInput = 0f;
		if(Input.GetKey(KeyCode.E))
			verticalInput = 1f;
		else if(Input.GetKey(KeyCode.Q))
			verticalInput = -1f;

		if(transform.position.y < 0f)
			verticalInput = Mathf.Max(0f, verticalInput);
		else if(transform.position.y > 60f)
			verticalInput = Mathf.Min(0f, verticalInput);

        // Determine current speed (boost if Left Shift is held)
        float currentSpeed = moveSpeed;
		if(Input.GetKey(KeyCode.LeftShift))
			currentSpeed *= boostMultiplier;

		// Calculate and apply movement (without normalization for snappy response)
		Vector3 movement = (transform.forward * forwardInput) +
						   (transform.right * rightInput) +
						   (transform.up * verticalInput);

		transform.position += movement * currentSpeed * Time.deltaTime;

		// --- Rotation & Cursor Locking (only when right mouse button is held) ---
		if(Input.GetMouseButton(1))  // Right mouse button held (index 1)
		{
			// Lock and hide the cursor
			Cursor.lockState = CursorLockMode.Locked;
			Cursor.visible = false;

			// Update rotation based on mouse movement
			yaw += Input.GetAxis("Mouse X") * rotationSpeed;
			pitch -= Input.GetAxis("Mouse Y") * rotationSpeed;
			pitch = Mathf.Clamp(pitch, -90f, 90f);

			transform.eulerAngles = new Vector3(pitch, yaw, 0f);
		}
		else
		{
			// When right mouse button is not held, unlock and show the cursor
			Cursor.lockState = CursorLockMode.None;
			Cursor.visible = true;
		}
	}
}