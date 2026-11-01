package com.ioc.springcoredemo.common;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import org.springframework.stereotype.Component;

// Repasse en singleton apres l'exercice 5.6 : @PreDestroy n'est jamais appele
// sur un bean prototype, que le conteneur ne suit plus une fois cree.
@Component
public class CricketCoach implements Coach {

	public CricketCoach() {
		System.out.println("In constructor: " + getClass().getSimpleName());
	}

	@PostConstruct
	public void doMyStartupStuff() {
		System.out.println("In doMyStartupStuff()");
	}

	@PreDestroy
	public void doMyCleanupStuff() {
		System.out.println("In doMyCleanupStuff()");
	}

	@Override
	public String getDailyWorkout() {
		return "Practice fast bowling for 15 minutes";
	}

}
