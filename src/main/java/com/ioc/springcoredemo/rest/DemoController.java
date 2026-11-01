package com.ioc.springcoredemo.rest;

import com.ioc.springcoredemo.common.Coach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DemoController {

	/** Le coach expose par /dailyworkout. Exercice 5.8 : declare par @Bean. */
	private Coach workoutCoach;

	/** Les deux references comparees par /check. Exercice 5.6 : meme bean. */
	private Coach myCoach;

	private Coach anotherCoach;

	// Trois parametres parce que deux exercices se superposent dans l'etat
	// final : 5.8 veut le coach « aquatic » sur /dailyworkout, 5.6 veut deux
	// injections du meme cricketCoach pour comparer les references.
	@Autowired
	public DemoController(
			@Qualifier("aquatic") Coach theWorkoutCoach,
			@Qualifier("cricketCoach") Coach theCoach,
			@Qualifier("cricketCoach") Coach theAnotherCoach) {
		workoutCoach = theWorkoutCoach;
		myCoach = theCoach;
		anotherCoach = theAnotherCoach;
	}

	@GetMapping("/dailyworkout")
	public String getDailyWorkout() {
		return workoutCoach.getDailyWorkout();
	}

	@GetMapping("/check")
	public String check() {
		return "Comparing beans: myCoach == anotherCoach, " + (myCoach == anotherCoach);
	}

}
