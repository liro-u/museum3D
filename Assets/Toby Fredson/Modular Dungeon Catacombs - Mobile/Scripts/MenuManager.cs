﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MenuManager : MonoBehaviour {
	// Changed to GameObject because only the game object of the menu needs to be accessed, you can 
	// change this to any class that inherits MonoBehaviour
	public GameObject optionsMenu;

	// Update is called once per frame
	void Update () 
	{
		// Reverse the active state every time escape is pressed
		if (Input.GetKeyDown(KeyCode.H))

		{
			// Check whether it's active / inactive 
			bool isActive = optionsMenu.activeSelf;

			optionsMenu.SetActive(!isActive);

		}
			
	}
}
