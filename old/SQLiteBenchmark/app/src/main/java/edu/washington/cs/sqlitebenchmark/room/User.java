package edu.washington.cs.sqlitebenchmark.room;

import android.arch.persistence.room.Entity;
import android.arch.persistence.room.Index;
import android.arch.persistence.room.PrimaryKey;
import android.support.annotation.NonNull;

/**
 * Created by nl35 on 11/13/17.
 */

@Entity(primaryKeys = {"firstName", "lastName"},
        indices = {@Index(value = {"firstName", "lastName"}, unique = true)})
public class User {
    @NonNull
    public String firstName;

    @NonNull
    public String lastName;

    public String status;
}
