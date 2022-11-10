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

import java.util.ArrayList;
import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.azure.core.credential.TokenRequestContext;
import com.azure.identity.DefaultAzureCredential;
import com.azure.identity.DefaultAzureCredentialBuilder;

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

    @GetMapping
    public String getAccessToken() {
        DefaultAzureCredentialBuilder builder = new DefaultAzureCredentialBuilder();

        DefaultAzureCredential credential = builder.build();

        TokenRequestContext request = new TokenRequestContext();
        ArrayList<String> scopes = new ArrayList<>();
        scopes.add("https://ossrdbms-aad.database.windows.net");
        request.setScopes(scopes);
        return credential.getToken(request).block().getToken();
    }

}
