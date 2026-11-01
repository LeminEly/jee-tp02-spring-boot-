package com.ioc.springcoredemo.common;

import java.util.UUID;
import org.springframework.context.annotation.Scope;
import org.springframework.context.annotation.ScopedProxyMode;
import org.springframework.stereotype.Component;
import org.springframework.web.context.WebApplicationContext;

/**
 * Bonus 1 : un bean de portee requete.
 *
 * <p>Le mandataire est indispensable. DemoController est un singleton, cree une
 * fois pour toutes ; sans proxyMode il capturerait la premiere instance
 * rencontree et la servirait a toutes les requetes suivantes. Le mandataire
 * delegue a l'instance de la requete en cours.
 */
@Component
@Scope(value = WebApplicationContext.SCOPE_REQUEST, proxyMode = ScopedProxyMode.TARGET_CLASS)
public class RequestIdentity {

	private final String identifiant = UUID.randomUUID().toString();

	public String getIdentifiant() {
		return identifiant;
	}

}
