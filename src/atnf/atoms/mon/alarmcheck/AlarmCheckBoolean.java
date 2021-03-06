//
// Copyright (C) CSIRO Australia Telescope National Facility
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Library General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.

package atnf.atoms.mon.alarmcheck;

import org.apache.log4j.Logger;

import atnf.atoms.mon.*;

/**
 * <i>AlarmCheck</i> sub-class which checks if a Boolean data-value will raise an alarm or not. The Boolean argument determines
 * whether a <i>true</i> or <i>false</i> value will raise an alarm. An optional second argument (default=1) determines how many
 * consecutive updates are required before alarming.
 * 
 * @author Camille Nicodemus
 */
public class AlarmCheckBoolean extends AlarmCheck {
  /**
   * The determined boolean that will raise an alarm
   */
  private boolean itsBoolean = new Boolean("true");

  /**
   * Minimum amount of times a value must appear in a row before raising an alarm
   */
  private int itsUpdateAmt = 0;

  /**
   * The amount of times an alarm value has appeared in a row
   */
  private int itsBoolCount = 0;

  public AlarmCheckBoolean(PointDescription parent, String[] args) throws IllegalArgumentException {
    super(parent, args);

    try {
      // Parse first argument to a Boolean type. This defines the Boolean
      // value that will cause an alarm
      // to be set.
      itsBoolean = Boolean.parseBoolean(args[0]);

      // Parse second argument to an Integer type. This is the number of
      // times a value should appear before
      // setting the alarm to True.
      // If no argument has been specified this defaults to an update
      // amount of 1.
      if (args.length > 1) {
        itsUpdateAmt = Integer.parseInt(args[1]);
      } else {
        itsUpdateAmt = 1;
      }
    } catch (Exception e) {
      Logger logger = Logger.getLogger(Factory.class.getName());
      logger.error("AlarmCheckBoolean: Maximum two arguments required!");
    }
  }

  /**
   * Checks if the value will raise an alarm with respect to the determined Boolean alarm value.
   * 
   * @param data
   *          The value to check against our limits.
   * @return Always true.
   */
  public boolean checkAlarm(PointData data) {
    // No news is good news, right?
    if (data == null || data.getData() == null) {
      return true;
    }

    Object myData = data.getData();

    boolean boolData = new Boolean("true");
    // Get the data as a boolean
    if (myData instanceof Boolean) {
      boolData = ((Boolean) myData).booleanValue();
    } else {
      Logger logger = Logger.getLogger(Factory.class.getName());
      logger.error("AlarmCheckBoolean: ERROR: " + data.getName() + " has NON-BOOLEAN data!");
      return true;
    }

    // If the data matches the defined boolean value to raise an alarm,
    // increment the alarm count.
    if (boolData == itsBoolean) {
      itsBoolCount++;
    } else { // Otherwise set it to zero.
      itsBoolCount = 0;
    }

    // Check the number of times the boolean value has been set to the
    // specified value.
    // If this is the same as the amount specified in the config file, set
    // the alarm to True.
    if (itsBoolCount >= itsUpdateAmt) {
      data.setAlarm(true);
    }
    return true;
  }
}
