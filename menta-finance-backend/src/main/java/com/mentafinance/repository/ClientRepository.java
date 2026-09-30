package com.mentafinance.repository;

import com.mentafinance.entity.Client;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ClientRepository extends JpaRepository<Client, Long> {

    // Kwa search box ya Clients screen (mf. mtu anaandika "Heaven"
    // na anataka aone "Heaven Apartment") - IgnoreCase = haijali herufi
    // kubwa/ndogo, Containing = "kama" (LIKE %..%)
    List<Client> findByNameContainingIgnoreCase(String name);
}
