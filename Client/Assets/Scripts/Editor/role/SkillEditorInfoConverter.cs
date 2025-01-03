using System;
using System.Collections.Generic;
using System.Reflection;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using UnityEngine;
namespace wc.framework
{
    public class EnumConverter<TEnum> : JsonConverter
        where TEnum : struct, Enum
    {
        public override void WriteJson(JsonWriter writer, object value, JsonSerializer serializer)
        {
            writer.WriteValue(value.ToString());
        }

        public override object ReadJson(JsonReader reader, Type objectType, object existingValue, JsonSerializer serializer)
        {
            if (reader.TokenType == JsonToken.String)
            {
                string enumString = reader.Value.ToString();
                if (Enum.TryParse(enumString, out TEnum result))
                {
                    return result;
                }
            }
            throw new JsonSerializationException($"Invalid value '{reader.Value}' for type {objectType}");
        }

        public override bool CanConvert(Type objectType)
        {
            return objectType == typeof(TEnum);
        }
    }

    public class Vector3Converter : JsonConverter
{
    public override bool CanConvert(Type objectType)
    {
        return objectType == typeof(Vector3);
    }

    public override void WriteJson(JsonWriter writer, object value, JsonSerializer serializer)
    {
        Vector3 vector = (Vector3)value;
        writer.WriteStartObject();
        writer.WritePropertyName("x");
        writer.WriteValue(vector.x);
        writer.WritePropertyName("y");
        writer.WriteValue(vector.y);
        writer.WritePropertyName("z");
        writer.WriteValue(vector.z);
        writer.WriteEndObject();
    }

    public override object ReadJson(JsonReader reader, Type objectType, object existingValue, JsonSerializer serializer)
    {
        JObject jsonObject = JObject.Load(reader);
        return new Vector3(
            (float)jsonObject["x"],
            (float)jsonObject["y"],
            (float)jsonObject["z"]
        );
    }
}
}