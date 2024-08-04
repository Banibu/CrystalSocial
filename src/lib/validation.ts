import { z } from "zod";

const requiredString = z.string().trim().min(1, "Required");

export const signUpSchema = z.object({
  email: requiredString.email("Endereço de email invalido"),
  username: requiredString.regex(
    /^[a-zA-Z0-9_-]+$/,
    "Somente letras, números, - e _ são permitidos",
  ),
  password: requiredString.min(8, "Deve ter pelo menos 8 caracteres"),
});

export type SignUpValues = z.infer<typeof signUpSchema>;

export const loginSchema = z.object({
  username: requiredString,
  password: requiredString,
});

export type LoginValues = z.infer<typeof loginSchema>;

export const createPostSchema = z.object({
  content: requiredString,
  mediaIds: z.array(z.string()).max(5, "Não pode ter mais de 5 anexos"),
});

export const updateUserProfileSchema = z.object({
  displayName: requiredString,
  bio: z.string().max(1000, "Deve ter no máximo 1000 caracteres"),
});

export type UpdateUserProfileValues = z.infer<typeof updateUserProfileSchema>;

export const createCommentSchema = z.object({
  content: requiredString,
});
