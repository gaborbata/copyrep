/*
 *  acme-service.js
 *
 *  Copyright (c) 2018 by Acme Company. All rights reserved.
 *
 *  The copyright to the computer software herein is the property of
 *  Acme Company. The software may be used and/or copied only
 *  with the written permission of Acme Company or in accordance
 *  with the terms and conditions stipulated in the agreement/contract
 *  under which the software has been supplied.
 */

define([
    './module'
], function (module) {
    'use strict';

    /**
     * @name AcmeService
     * @type service
     */
    module.service('AcmeService', [
        'AcmeService',
        '$q',
        '$http',
        function (
            acmeDataService,
            $q,
            $http
        ) {
            var acmeService = this;
            var apiGatewayUrl = acmeDataService.getServiceURL();

            this.getTnt = function (id) {
                return $http.get(apiGatewayUrl + '/tnt/' + id).then(function (response) {
                    return response.data;
                });
            };
        }
    ]);

    return module;
});
