/*
 * Copyright 2002-2017 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.springframework.samples.petclinic.identitydemo.web;

import lombok.RequiredArgsConstructor;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.azure.core.credential.TokenCredential;
import com.azure.core.credential.TokenRequestContext;
import com.azure.identity.DefaultAzureCredential;
import com.azure.identity.DefaultAzureCredentialBuilder;
import com.azure.identity.ManagedIdentityCredential;
import com.azure.identity.ManagedIdentityCredentialBuilder;
import com.azure.identity.providers.jdbc.implementation.enums.AuthProperty;
import com.azure.identity.providers.jdbc.implementation.template.AzureAuthenticationTemplate;
import com.azure.core.util.Configuration;

/**
 * @author Juergen Hoeller
 * @author Mark Fisher
 * @author Ken Krebs
 * @author Arjen Poutsma
 * @author Maciej Szarlinski
 */
@RequestMapping("/identity")
@RestController
@RequiredArgsConstructor
class IdentityResource {

    private static final String OSSRDBMS_SCOPE = "https://ossrdbms-aad.database.windows.net/.default";

    @GetMapping
    public String getAccessToken() {
        DefaultAzureCredentialBuilder builder = new DefaultAzureCredentialBuilder();

        DefaultAzureCredential credential = builder.build();

        return getToken(credential);
    }


    @GetMapping(value ="/msi")
    public String getAksToken(){
        ManagedIdentityCredentialBuilder builder = new ManagedIdentityCredentialBuilder();
        builder.configuration(Configuration.getGlobalConfiguration());
        ManagedIdentityCredential msicreds = builder.build();
        return getToken(msicreds);
    }


    private String getToken(TokenCredential crendential) {
        TokenRequestContext request = new TokenRequestContext();
        ArrayList<String> scopes = new ArrayList<>();
        scopes.add("https://ossrdbms-aad.database.windows.net/.default");
        request.setScopes(scopes);
        return crendential.getToken(request).block().getToken();
    }

    private String getTokenDontWork(TokenCredential crendential) {
        TokenRequestContext request = new TokenRequestContext();
        ArrayList<String> scopes = new ArrayList<>();
        scopes.add("https://ossrdbms-aad.database.windows.net/.default");
        request.setScopes(scopes);
        return crendential.getToken(request).block().getToken();
    }


    @GetMapping(value ="/time")
    public String getServerTime() throws SQLException{
        String url = "jdbc:mysql://mysql-petclinic-ms-182746-dev.mysql.database.azure.com:3306/db?useSSL=true&user=identity-demo&authenticationPlugins=com.azure.identity.providers.mysql.AzureIdentityMysqlAuthenticationPlugin";
        Connection connection= DriverManager.getConnection(url);
        ResultSet results = connection.createStatement().executeQuery("select now() as now");
        if (results.next()) {
            return results.getString("now");
        }
        return "no result";
    }

    @GetMapping(value="/template")
    public String getTemplate(){
        AzureAuthenticationTemplate template = new AzureAuthenticationTemplate();
        Properties properties = new Properties();
        AuthProperty.SCOPES.setProperty(properties, OSSRDBMS_SCOPE);
        template.init(properties);
        String token = template.getTokenAsPasswordAsync().block();
        return token;
    }

}
