package com.ioc.springcoredemo.common;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.NoUniqueBeanDefinitionException;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Exercice 5.4 : la regle de priorite entre {@code @Primary} et
 * {@code @Qualifier}, et le piege des deux beans primaires.
 *
 * <p>Ces trois situations ne peuvent pas coexister dans le code livre : le
 * depot ne porte qu'un seul etat a la fois. Elles vivent donc ici, ou chacune
 * est rejouable.
 */
class PrimaryVersusQualifierTest {

	private final ApplicationContextRunner conteneur = new ApplicationContextRunner()
			.withUserConfiguration(CoachsAvecUnPrimaire.class);

	@Test
	void sansQualifierLeBeanPrimaireEstChoisi() {
		conteneur.withUserConfiguration(ConsommateurSansQualifier.class)
				.run(contexte -> assertThat(contexte).hasNotFailed()
						.getBean("choisi", Coach.class)
						.isInstanceOf(TrackCoach.class));
	}

	@Test
	void leQualifierGagneSurLePrimaire() {
		conteneur.withUserConfiguration(ConsommateurAvecQualifier.class)
				.run(contexte -> assertThat(contexte).hasNotFailed()
						.getBean("choisi", Coach.class)
						.isInstanceOf(CricketCoach.class));
	}

	@Test
	void deuxBeansPrimairesEmpechentLeDemarrage() {
		new ApplicationContextRunner()
				.withUserConfiguration(CoachsAvecDeuxPrimaires.class, ConsommateurSansQualifier.class)
				.run(contexte -> {
					assertThat(contexte).hasFailed();
					assertThat(contexte.getStartupFailure())
							.rootCause()
							.isInstanceOf(NoUniqueBeanDefinitionException.class)
							.hasMessageContaining("more than one 'primary' bean");
				});
	}

	@Configuration(proxyBeanMethods = false)
	static class CoachsAvecUnPrimaire {

		@Bean
		CricketCoach cricketCoach() {
			return new CricketCoach();
		}

		@Bean
		@Primary
		TrackCoach trackCoach() {
			return new TrackCoach();
		}

	}

	@Configuration(proxyBeanMethods = false)
	static class CoachsAvecDeuxPrimaires {

		@Bean
		@Primary
		CricketCoach cricketCoach() {
			return new CricketCoach();
		}

		@Bean
		@Primary
		TrackCoach trackCoach() {
			return new TrackCoach();
		}

	}

	@Configuration(proxyBeanMethods = false)
	static class ConsommateurSansQualifier {

		@Bean
		Coach choisi(Coach coach) {
			return coach;
		}

	}

	@Configuration(proxyBeanMethods = false)
	static class ConsommateurAvecQualifier {

		@Bean
		Coach choisi(@Qualifier("cricketCoach") Coach coach) {
			return coach;
		}

	}

}
