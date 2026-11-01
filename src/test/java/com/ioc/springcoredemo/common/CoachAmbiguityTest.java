package com.ioc.springcoredemo.common;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.NoUniqueBeanDefinitionException;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Exercice 5.2 : l'ambiguite que l'enonce demande de provoquer.
 *
 * <p>Ce test existe parce que la preuve ne peut pas vivre ailleurs. Laisser
 * l'application reellement incapable de demarrer dans un commit ferait echouer
 * le {@code contextLoads} genere, donc la porte de pre-commit, donc
 * l'integration continue. L'ambiguite est donc reproduite dans un conteneur
 * isole : quatre {@link Coach} candidats, un point d'injection sans qualifier.
 *
 * <p>Le test est vert quand le demarrage echoue. C'est voulu : ce qu'il affirme,
 * c'est que Spring refuse de choisir a notre place.
 */
class CoachAmbiguityTest {

	private final ApplicationContextRunner conteneur = new ApplicationContextRunner()
			.withUserConfiguration(CoachsRivaux.class);

	@Test
	void quatreCandidatsSansQualifierEmpechentLeDemarrage() {
		conteneur.withUserConfiguration(ConsommateurSansQualifier.class).run(contexte -> {
			assertThat(contexte).hasFailed();
			assertThat(contexte.getStartupFailure())
					.rootCause()
					.isInstanceOf(NoUniqueBeanDefinitionException.class)
					.hasMessageContainingAll("baseballCoach", "cricketCoach", "tennisCoach", "trackCoach");
		});
	}

	@Test
	void leMemeConteneurDemarreDesQuUnQualifierTranche() {
		conteneur.withUserConfiguration(ConsommateurAvecQualifier.class)
				.run(contexte -> assertThat(contexte).hasNotFailed());
	}

	/**
	 * Les quatre implementations, declarees ici sous les memes identifiants que
	 * ceux que le balayage de composants leur donnerait.
	 */
	@Configuration(proxyBeanMethods = false)
	static class CoachsRivaux {

		@Bean
		CricketCoach cricketCoach() {
			return new CricketCoach();
		}

		@Bean
		BaseballCoach baseballCoach() {
			return new BaseballCoach();
		}

		@Bean
		TennisCoach tennisCoach() {
			return new TennisCoach();
		}

		@Bean
		TrackCoach trackCoach() {
			return new TrackCoach();
		}

	}

	@Configuration(proxyBeanMethods = false)
	static class ConsommateurSansQualifier {

		@Bean
		String resume(Coach coach) {
			return coach.getDailyWorkout();
		}

	}

	@Configuration(proxyBeanMethods = false)
	static class ConsommateurAvecQualifier {

		@Bean
		String resumeQualifie(@Qualifier("cricketCoach") Coach coach) {
			return coach.getDailyWorkout();
		}

	}

}
