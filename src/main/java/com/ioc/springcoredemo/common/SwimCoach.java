package com.ioc.springcoredemo.common;

// Volontairement sans @Component : c'est le cas d'une classe que l'on ne peut
// pas annoter, par exemple parce qu'elle vient d'une bibliotheque tierce. Le
// balayage de composants l'ignore donc, et c'est SportConfig qui l'enregistre.
public class SwimCoach implements Coach {

	public SwimCoach() {
		System.out.println("In constructor: " + getClass().getSimpleName());
	}

	@Override
	public String getDailyWorkout() {
		return "Swim 1000 meters as a warm up";
	}

}
