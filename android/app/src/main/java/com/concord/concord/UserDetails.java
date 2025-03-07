package com.concord.concord;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import java.util.ArrayList;
import java.util.Objects;

/** Generated class from Pigeon that represents data sent in messages. */
public final class UserDetails {
  private @Nullable String name;

  public @Nullable String getName() {
    return name;
  }

  public void setName(@Nullable String setterArg) {
    this.name = setterArg;
  }

  private @Nullable String email;

  public @Nullable String getEmail() {
    return email;
  }

  public void setEmail(@Nullable String setterArg) {
    this.email = setterArg;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) { return true; }
    if (o == null || getClass() != o.getClass()) { return false; }
    UserDetails that = (UserDetails) o;
    return Objects.equals(name, that.name) && Objects.equals(email, that.email);
  }

  @Override
  public int hashCode() {
    return Objects.hash(name, email);
  }

  public static final class Builder {

    private @Nullable String name;

    public @NonNull Builder setName(@Nullable String setterArg) {
      this.name = setterArg;
      return this;
    }

    private @Nullable String email;

    public @NonNull Builder setEmail(@Nullable String setterArg) {
      this.email = setterArg;
      return this;
    }

    public @NonNull UserDetails build() {
      UserDetails pigeonReturn = new UserDetails();
      pigeonReturn.setName(name);
      pigeonReturn.setEmail(email);
      return pigeonReturn;
    }
  }

  @NonNull
  ArrayList<Object> toList() {
    ArrayList<Object> toListResult = new ArrayList<>(2);
    toListResult.add(name);
    toListResult.add(email);
    return toListResult;
  }

  static @NonNull UserDetails fromList(@NonNull ArrayList<Object> pigeonVar_list) {
    UserDetails pigeonResult = new UserDetails();
    Object name = pigeonVar_list.get(0);
    pigeonResult.setName((String) name);
    Object email = pigeonVar_list.get(1);
    pigeonResult.setEmail((String) email);
    return pigeonResult;
  }
} 