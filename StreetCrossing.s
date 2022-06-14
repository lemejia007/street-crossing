
// to compile: g++ StreetCrossing.s -lwiringPi -g -o StreetCrossing

// This is a simple assembly program where hardware and software communicate to reenact
// a street corssing for both traffic and pedestrians. When the button is pressed, the
// red traffic light lights up and the green walking light lights up. After a couple of
// seconds, the yellow traffic light and the green pedestraisn light flash to signal
// walking will come to an end. Lastly, the green traffic light and the red pedestrain
// light turn on to signal cars may continue.


// Map LEDs/bread board, wiring pins
.equ INPUT, 0 		          // Equate INPUT              to 0
.equ OUTPUT, 1 		          // Equate OUTPUT             to 1
.equ LOW, 0 		            // Equate LOW                to 0
.equ HIGH, 1 		            // Equate HIGH               to 1
.equ SECONDS_PAUSE, 5	      // EQUATE SECONDS_PAUSE	 to 5
.equ RED_TRAFFIC_PIN, 25    // Equate RED_TRAFFIC_PIN    to 25 -> BCM 26/ wPi 25/ Physical 37
.equ YELLOW_TRAFFIC_PIN, 24 // Equate YELLOW_TRAFFIC_PIN to 24 -> BCM 19/ wPi 24/ Physical 35
.equ GREEN_TRAFFIC_PIN, 23  // Equate GREEN_TRAFFIC_PIN  to 23 -> BCM 13/ wPi 23/ Physical 33
.equ RED_WALKING_PIN, 29    // Equate RED_WALKING_PIN    to 29 -> BCM 21/ wPi 29/ Physical 40
.equ GREEN_WALKING_PIN, 28  // Equate GREEN_WALKING_PIN  to 28 -> BCM 20/ wPi 28/ Physical 38
.equ START_PIN, 27	        // Equate START_PIN          to 27 -> BCM 16/ wPi 27/ Physical 36

.align 4
.text
.global main

main:
// int main()

	  // {

	push {lr} 	                 // Save calling address
	bl wiringPiSetup             // Initialize the wiringPi library

	mov r0, #START_PIN
	bl setPinInput		           // Set start pin for input

	mov r0, #RED_TRAFFIC_PIN
	bl setPinOutput		           // Set red traffic light for output
	bl pinOff		                 // Assure red traffic light is off

	mov r0, #YELLOW_TRAFFIC_PIN
	bl setPinOutput		           // Set yellow traffic light for output
	bl pinOff		                 // Assure yellow traffic light is off

	mov r0, #GREEN_TRAFFIC_PIN
	bl setPinOutput		           // Set green traffic light for output
	bl pinOff		                 // Assure green traffic light is off

	mov r0, #GREEN_WALKING_PIN
	bl setPinOutput		           // Set green walking light for output
	bl pinOff		                 // Assure green walking light is off

	mov r0, # RED_WALKING_PIN
	bl setPinOutput		           // Set red walking light for output
	bl pinOff		                 // Assure red walking light is off

phase_1:

	mov r0, #RED_WALKING_PIN
	bl pinOn		                 // Turn the red walking light on

	mov r1, #GREEN_TRAFFIC_PIN   // Turn green traffic light on
	bl action

	mov r0, #RED_WALKING_PIN
	bl pinOff		                 // Turn red walking light off

	mov r0, #GREEN_TRAFFIC_PIN
	bl pinOff		                 // Turn green traffic light off

	mov r0, #RED_TRAFFIC_PIN
	bl pinOn		                 // Turn red traffic light On

	mov r0, #GREEN_WALKING_PIN
	bl pinOn		                 // Turn green walking light on

	ldr r0, =10000
	bl delay		                 // Delay program for 10 seconds

phase_2:
	mov r0, #RED_TRAFFIC_PIN
	bl pinOff		                 // Turn red Traffic light off

	mov r0, #GREEN_WALKING_PIN
	bl pinOff		                 // Turn green walking light off

	bl blinkLights	             // Blink lights

phase_3:
	mov r0, #GREEN_TRAFFIC_PIN
	bl pinOn		                 // Turn green traffic light on

	mov r0, #RED_WALKING_PIN
	bl pinOn		                 // Turn red walking light on

	ldr r0, =10000
	bl delay		                 // Delay program for 10 seconds

	mov r0, #GREEN_TRAFFIC_PIN
	bl pinOff                    // Turn green traffic light off

	mov r0, #RED_WALKING_PIN
	bl pinOff                    // Turn red walking light ofdf

	mov r0, #GREEN_TRAFFIC_PIN
	bl pinOff                    // Assure green traffic light is off

	mov r0, #RED_WALKING_PIN
	bl pinOff                    // Assure red walking light is off

	mov r0, #0	  	             // Return 0
	pop {pc} 	  	               // Retrieve calling address

// }


// Sets a wiring pin for input
setPinInput:
	push {lr}
	mov r1, #INPUT
	bl pinMode
	pop {pc}


// Sets a wiring pin for output
setPinOutput:
	push {lr}
	mov r1, #OUTPUT
	bl pinMode
	pop {pc}


// Provides a wiring pin between 3.3v-5.0v
pinOn:
	push {lr}
	mov r1, #HIGH
	bl digitalWrite
	pop {pc}


// Stops voltage to a wiring pin
pinOff:
	push {lr}
	mov r1, #LOW
	bl digitalWrite
	pop {pc}


// Reads the tactile button high voltage
// returns return value: r0=0, no user interation; r0=1 user pressed stop button
readStartButton:
	push {lr}
	mov r0, #START_PIN
	bl digitalRead
	pop {pc}


// Turns an LED on and waits until a high voltage is read
// r1 holds pin to turn on
// return value: r0=0, no user interation; r0=1 user pressed stop button
action:
        push {r4, lr}
        mov r4, r1
        bl pinOff
        mov r0, r4
        bl pinOn
do_whl:
        bl readStartButton
        cmp r0, #HIGH
        beq action_done
        blt do_whl
        mov r0, #0
action_done:
        pop {r4, pc}


// Blinks yellow traffic LED and green walking LED
// Register R4 serves as a counter
blinkLights:
        push {r4, lr}
        mov r4, #7
blinkLightsLoop:
        cmp r4, #0
        beq phase_3

        mov r0, #YELLOW_TRAFFIC_PIN
        bl pinOn

        mov r0, #GREEN_WALKING_PIN
        bl pinOn

        mov r0, #1000
        bl delay

        mov r0, #YELLOW_TRAFFIC_PIN
        bl pinOff

        mov r0, #GREEN_WALKING_PIN
        bl pinOff

        mov r0, #1000
        bl delay

        sub r4, #1
        bal blinkLightsLoop
