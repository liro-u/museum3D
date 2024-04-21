using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerColliding : MonoBehaviour
{
    private const string BatteryTag = "Battery";
    private const string GunTag = "Gun";
    private const string FLTag = "FL";
    private const string EnemyTag = "Enemy";
    private const string ExitTag = "Exit";
    private const string Exit1Tag = "Exit1";
    private const string Enter1Tag = "Enter1";
    private const string EnterMontSaintMichelTag = "Mont";
    private const string Exit4Tag = "Exit4";
    private const string Chest1Tag = "Chest1";
    private const string Chest2Tag = "Chest2";
    private const string Chest3Tag = "Chest3";
    private const string KeyTag = "rustKey";
    private const string KeyChest2Tag = "rustKeyChest2";

    private GameManager _gameManager;
    private Animator chestAnimator;
    private bool canPickUpFL = false;
    private bool canPickUpGun = false;
    private bool canOpenChest = false;
    private bool canOpenDoor1 = false;
    private bool canOpenDoor2 = false;
    private bool canOpenDoor3 = false;
    private bool chest1Opened = false;
    private bool chest2Opened = false;
    private bool chest3Opened = false;
    private bool door1Opened = false;
    private bool haveKey1 = false;
    private bool haveKey2 = false;
    private bool haveKey3 = false;
    private bool haveChestKey2 = false;
    private bool canOpenChest2 = false;
    private bool isChest1 = false;
    private bool isChest2 = false;
    private bool isChest3 = false;
    private bool canPickupChestKey2 = false;
    private bool haveGun = false;
    private bool FLisOn = false;

    private void Awake()
    {

    }

    private void Start()
    {
        _gameManager = GameManager.Instance;
    }

    private void Update()
    {
        if (canPickUpGun && Input.GetKeyDown(KeyCode.E))
        {
            haveGun = true;
            int weaponIndex = 0;
            GameObject gun = GameObject.FindWithTag("Gun");
            _gameManager.canvas.transform.GetChild(2).gameObject.SetActive(false);
            Destroy(gun);
            _gameManager.setActive(0);
            canPickUpGun = false; // Reset flag
        }
        if (haveGun) {
            _gameManager.canvas.transform.GetChild(2).gameObject.SetActive(false);
            GameObject gun = GameObject.FindWithTag("Gun");
            Destroy(gun);
        }

        if (canPickUpFL && Input.GetKeyDown(KeyCode.E))
        {
            int weaponIndex = 1;
            GameObject fl = GameObject.FindWithTag("FL");
            _gameManager.canvas.transform.GetChild(3).gameObject.SetActive(false);
            Destroy(fl);
            canPickUpFL = false;
            _gameManager.setActive(1);
            _gameManager.canvas.transform.GetChild(8).gameObject.SetActive(true);
        }




        /*if (canOpenChest && Input.GetKeyDown(KeyCode.O))
            {
                if (isChest1)
                {
                    if (chestAnimator != null && !chest1Opened) // Open the chest if not already opened.
                    {
                        chestAnimator.SetBool("Activate", true); // Trigger chest opening animation.
                        chest1Opened = true; // Mark the chest as opened.
                    }
                    else
                    {
                        chestAnimator.SetBool("Activate", true); // Trigger chest opening animation.
                        chest1Opened = false;
                    }
                    // Assuming you want to toggle, but you had set chest1Opened = false in an else block directly after another action. This needs careful handling.
                }
                else if (isChest3) // Corrected placement for else if to handle isChest3 logic.
                {
                    if (chestAnimator != null && !chest3Opened) // Open the chest if not already opened.
                    {
                        chestAnimator.SetBool("Activate", true); // Trigger chest opening animation.
                        chest3Opened = true; // Mark the chest as opened.
                    }
                }
                else
                {
                    chestAnimator.SetBool("Activate", true); // Trigger chest opening animation.
                    chest3Opened = false;
                }
            }


            // Open the chest with KeyCode.O
            if (canOpenChest2 && Input.GetKeyDown(KeyCode.O))
            {
                if (isChest2)
                {
                    if (chestAnimator != null && !chest2Opened) // Open the chest if not already opened.
                    {
                        chestAnimator.SetBool("Activate", true); // Trigger chest opening animation.
                        chest2Opened = true; // Mark the chest as opened.

                        //_gameManager.canvas.transform.GetChild(5).GetChild(0).gameObject.SetActive(true);  Assuming this shows a prompt to pick up the key.
                    }
                    else
                    {
                        chestAnimator.SetBool("Activate", true); // Trigger chest opening animation.
                        chest2Opened = false;
                    }
                }
            }

            if (canPickupChestKey2 && Input.GetKeyDown(KeyCode.E))
            {
                GameObject keyChest2 = GameObject.FindWithTag("rustKeyChest2");
                if (keyChest2 != null) // Ensure the key exists.
                {
                    keyChest2.SetActive(false); // Hide or "pick up" the key.
                    haveChestKey2 = true; // Player now has the key.
                    _gameManager.canvas.transform.GetChild(5).GetChild(3).gameObject.SetActive(true); // Optionally hide the prompt.
                }
            }

            // Pick up the key from the opened chest with KeyCode.E
            if (chest1Opened && Input.GetKeyDown(KeyCode.E))
            {
                GameObject key1 = GameObject.FindWithTag("rustKey");
                if (key1 != null) // Ensure the key exists.
                {
                    key1.SetActive(false); // Hide or "pick up" the key.
                    haveKey1 = true; // Player now has the key.
                    _gameManager.canvas.transform.GetChild(5).GetChild(0).gameObject.SetActive(true); // Optionally hide the prompt.
                }
            }
*/
    }

    public void OnCollisionEnter(Collision collision)
    {
        string url1 = "https://www.timographie360.fr/visites/visite-virtuelle/CMN/mont-saint-michel/?fbclid=IwAR2iypzYLU5_U4iuZESqf43Q1oWH47nn3OW0hdQ4TlJcadeTX2MWmJZcQVM";
        if (collision.gameObject.CompareTag(ExitTag))
        {
            _gameManager.Door1();
        }

        if (collision.gameObject.CompareTag(Enter1Tag))
        {
            _gameManager.Enter1();
        }

        if (collision.gameObject.CompareTag(EnterMontSaintMichelTag))
        {
            Application.OpenURL(url1);
        }
    }

    public void OnCollisionExit(Collision collision)
    {
    
    }
}
