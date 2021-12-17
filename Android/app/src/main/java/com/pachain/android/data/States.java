package com.pachain.android.data;

import android.database.sqlite.SQLiteDatabase;

public class States {
    public static void init(SQLiteDatabase database) {
        database.execSQL("DELETE FROM States");
        database.execSQL("INSERT INTO States (ID, Code, Name) SELECT 1,'AL','Alabama' UNION ALL SELECT 2,'AK','Alaska' UNION ALL SELECT 4,'AZ','Arizona' UNION ALL SELECT 5,'AR','Arkansas' UNION ALL SELECT 6,'CA','California' UNION ALL SELECT 8,'CO','Colorado' UNION ALL SELECT 9,'CT','Connecticut' UNION ALL SELECT 10,'DE','Delaware' UNION ALL SELECT 11,'DC','District of Columbia' UNION ALL SELECT 12,'FL','Florida' UNION ALL SELECT 13,'GA','Georgia' UNION ALL SELECT 15,'HI','Hawaii' UNION ALL SELECT 16,'ID','Idaho' UNION ALL SELECT 17,'IL','Illinois' UNION ALL SELECT 18,'IN','Indiana' UNION ALL SELECT 19,'IA','Iowa' UNION ALL SELECT 20,'KS','Kansas' UNION ALL SELECT 21,'KY','Kentucky' UNION ALL SELECT 22,'LA','Louisiana' UNION ALL SELECT 23,'ME','Maine' UNION ALL SELECT 24,'MD','Maryland' UNION ALL SELECT 25,'MA','Massachusetts' UNION ALL SELECT 26,'MI','Michigan' UNION ALL SELECT 27,'MN','Minnesota' UNION ALL SELECT 28,'MS','Mississippi' UNION ALL SELECT 29,'MO','Missouri' UNION ALL SELECT 30,'MT','Montana' UNION ALL SELECT 31,'NE','Nebraska' UNION ALL SELECT 32,'NV','Nevada' UNION ALL SELECT 33,'NH','New Hampshire' UNION ALL SELECT 34,'NJ','New Jersey' UNION ALL SELECT 35,'NM','New Mexico' UNION ALL SELECT 36,'NY','New York' UNION ALL SELECT 37,'NC','North Carolina' UNION ALL SELECT 38,'ND','North Dakota' UNION ALL SELECT 39,'OH','Ohio' UNION ALL SELECT 40,'OK','Oklahoma' UNION ALL SELECT 41,'OR','Oregon' UNION ALL SELECT 42,'PA','Pennsylvania' UNION ALL SELECT 44,'RI','Rhode Island' UNION ALL SELECT 45,'SC','South Carolina' UNION ALL SELECT 46,'SD','South Dakota' UNION ALL SELECT 47,'TN','Tennessee' UNION ALL SELECT 48,'TX','Texas' UNION ALL SELECT 49,'UT','Utah' UNION ALL SELECT 50,'VT','Vermont' UNION ALL SELECT 51,'VA','Virginia' UNION ALL SELECT 53,'WA','Washington' UNION ALL SELECT 54,'WV','West Virginia' UNION ALL SELECT 55,'WI','Wisconsin' UNION ALL SELECT 56,'WY','Wyoming'");
    }
}