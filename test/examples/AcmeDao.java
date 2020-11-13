/*
 * AcmeDao.java
 *
 * Copyright (c) 2019 by Acme Company. All rights reserved.
 *
 * The copyright to the computer software herein is the property of
 * Acme Company. The software may be used and/or copied only
 * with the written permission of Acme Company or in accordance
 * with the terms and conditions stipulated in the agreement/contract
 * under which the software has been supplied.
 */
package com.acme.dao;

public interface AcmeDao {

    /**
     * Check whether user has TNT access.
     * @param userId the user id
     * @return true if user has TNT access
     */
    public boolean hasTnt(String userId);
}
