package com.ioc.springcoredemo.rest;

import com.ioc.springcoredemo.common.Coach;
import com.ioc.springcoredemo.common.RequestIdentity;
import java.util.stream.Collectors;
import org.springframework.beans.factory.ObjectProvider;
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

	/**
	 * Bonus 2 : tous les beans de type Coach.
	 *
	 * <p>Un ObjectProvider plutot qu'un List<Coach> injecte directement, et ce
	 * n'est pas un detail de style. Mesure faite sur ce projet : injecter la
	 * liste au constructeur force la creation de TOUS les coachs au demarrage,
	 * TennisCoach compris, ce qui annule le @Lazy de l'exercice 5.5. Le
	 * fournisseur ne resout la collection qu'au premier appel de /allworkouts.
	 */
	private ObjectProvider<Coach> allCoaches;

	/** Bonus 1 : bean de portee requete, servi par un mandataire. */
	private RequestIdentity requestIdentity;

	// Les parametres s'accumulent parce que les exercices se superposent dans
	// l'etat final : 5.8 veut le coach aquatic sur /dailyworkout, 5.6 veut deux
	// injections du meme cricketCoach pour comparer les references.
	@Autowired
	public DemoController(
			@Qualifier("aquatic") Coach theWorkoutCoach,
			@Qualifier("cricketCoach") Coach theCoach,
			@Qualifier("cricketCoach") Coach theAnotherCoach,
			ObjectProvider<Coach> theCoaches,
			RequestIdentity theRequestIdentity) {
		workoutCoach = theWorkoutCoach;
		myCoach = theCoach;
		anotherCoach = theAnotherCoach;
		allCoaches = theCoaches;
		requestIdentity = theRequestIdentity;
	}

	@GetMapping("/dailyworkout")
	public String getDailyWorkout() {
		return workoutCoach.getDailyWorkout();
	}

	@GetMapping("/check")
	public String check() {
		return "Comparing beans: myCoach == anotherCoach, " + (myCoach == anotherCoach);
	}

	@GetMapping("/allworkouts")
	public String getAllWorkouts() {
		return allCoaches.stream()
				.map(coach -> coach.getClass().getSimpleName() + " : " + coach.getDailyWorkout())
				.collect(Collectors.joining("\n")) + "\n";
	}

	@GetMapping("/requestid")
	public String getRequestId() {
		return "Request id: " + requestIdentity.getIdentifiant() + "\n";
	}

}
