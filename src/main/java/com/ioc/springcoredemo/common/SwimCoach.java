package com.ioc.springcoredemo.common;

// Volontairement sans @Component : c'est le cas d'une classe que l'on ne peut
// pas annoter, par exemple parce qu'elle vient d'une bibliotheque tierce. Le
// balayage de composants l'ignore donc, et c'est SportConfig qui l'enregistre.
public class SwimCoach implements Coach {

	public SwimCoach() {
		System.out.println("In constructor: " + getClass().getSimpleName());
	}

	// Bonus 3 : le cycle de vie sans annoter la classe. Ces deux methodes ne
	// portent ni @PostConstruct ni @PreDestroy ; c'est SportConfig qui les
	// designe par les attributs initMethod et destroyMethod de @Bean. Utile
	// quand la classe vient d'ailleurs et qu'on ne peut pas l'annoter.
	public void startUp() {
		System.out.println("In startUp(): " + getClass().getSimpleName());
	}

	public void cleanUp() {
		System.out.println("In cleanUp(): " + getClass().getSimpleName());
	}

	@Override
	public String getDailyWorkout() {
		return "Swim 1000 meters as a warm up";
	}

}
