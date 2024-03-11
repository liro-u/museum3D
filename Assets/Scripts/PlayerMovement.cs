using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    [SerializeField] private CharacterController controller;

    [SerializeField] private float speed = 12f;
    [SerializeField] private float gravity = -9.81f;
    [SerializeField] private float jumpHeight = 2f;
    [SerializeField] private Transform Player;

    [SerializeField] private Transform groundCheck;
    [SerializeField] private float groundDistance = 0.4f;
    [SerializeField] private LayerMask groundMask;
    [SerializeField] private LayerMask tpGauche;
    [SerializeField] private LayerMask tpDroite;

    private Vector3 velocity;
    private bool isGrounded, isTpgauche, isTpdroite;

    // Update is called once per frame
    void Update()
    {
        isGrounded = Physics.CheckSphere(groundCheck.position, groundDistance, groundMask);
        isTpgauche = Physics.CheckSphere(groundCheck.position, groundDistance, tpGauche);
        isTpdroite = Physics.CheckSphere(groundCheck.position, groundDistance, tpDroite);

        if (isTpgauche)
        {
            controller.enabled = false;
            Player.position = new Vector3(160f, -26f, -210f);
            controller.enabled = true;
        }
        else if(isTpdroite)
        {
            controller.enabled = false;
            Player.position = new Vector3(77f, -26f, 280f);
            controller.enabled = true;
        }



        if (isGrounded && velocity.y < 0)
        {
            velocity.y = -2f;
        }

        float x = Input.GetAxis("Horizontal");
        float z = Input.GetAxis("Vertical");

        Vector3 move = transform.right * x + transform.forward * z;

        controller.Move(move * speed * Time.deltaTime);

        if (Input.GetButtonDown("Jump") && isGrounded)
        {
            velocity.y = Mathf.Sqrt(jumpHeight * -2f * gravity);
        }

        velocity.y += gravity * Time.deltaTime;

        controller.Move(velocity * Time.deltaTime);
    }
}
