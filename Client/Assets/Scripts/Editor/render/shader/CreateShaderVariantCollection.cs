using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

namespace wc.framework
{
	public class CreateShaderVariantCollection
	{
		private const string SHADER_ASSET_BUNDLE_NAME = "shaders";
		private const string SHADER_VARIANT_COLLECTION_PATH = "Assets/Resources/Res/Shader/ShaderVariants.shadervariants";
		
		private static Dictionary<Shader, HashSet<string>> _existingShaderKeywords =
			new Dictionary<Shader, HashSet<string>>();
		
		
		private static HashSet<string> GetShaderKeywords(string shaderFilePath) {
			var fullPath = Application.dataPath.Replace("Assets", "") + shaderFilePath;
			var keywords = new HashSet<string>();
			var shaderText = File.ReadAllText(shaderFilePath);
			var regex = new Regex(@"(?:#pragma shader_feature|#pragma multi_compile) ((?:\w+ ?)*)");
			MatchCollection matches = regex.Matches(shaderText);
			foreach(Match match in matches) {
				if(match.Groups.Count != 2) {
					Debug.LogError("Failed to parse shader keyword!");
				}
				string [] keyArray = match.Groups[1].Value.Split();
				foreach(var key in keyArray) {
					if(keywords.Contains(key))
						continue;
					keywords.Add(key);
				}
			}

			return keywords;
		}

		private static List<string> GetShaderDependenciesShaderPaths() {
			var shaderDependenciesAssetPaths = new List<string>();
			var shaderGuids = AssetDatabase.FindAssets("t: Shader");
			foreach(var shaderGuid in shaderGuids) {
				var shaderPath = AssetDatabase.GUIDToAssetPath(shaderGuid);
				if(AssetImporter.GetAtPath(shaderPath).assetBundleName == SHADER_ASSET_BUNDLE_NAME) {
					shaderDependenciesAssetPaths.Add(shaderPath);
				}
			}

			return shaderDependenciesAssetPaths;
		}

		private static List<Shader> GetShadersFromPaths(List<string> shaderPaths) {
			List<Shader> shaders = new List<Shader>();
			foreach(var shaderPath in shaderPaths) {
				shaders.Add(AssetDatabase.LoadAssetAtPath<Shader>(shaderPath));
			}

			return shaders;
		}

		public static List<Material> GetMaterialsUsingShaders(List<Shader> shaderDependenciesShaders) {
			var materialsUsingShaderDependencies = new List<Material>();

			var allMaterialGuids = AssetDatabase.FindAssets("t:Material");
			foreach(var matGuid in allMaterialGuids) {
				var mat = AssetDatabase.LoadAssetAtPath<Material>(AssetDatabase.GUIDToAssetPath(matGuid));

				if(shaderDependenciesShaders.Contains(mat.shader)) {
					materialsUsingShaderDependencies.Add(mat);
				}
			}

			return materialsUsingShaderDependencies;
		}

		private static string[] FilterExistingShaderKeywords(Shader shader, string[] materialKeywords) {
			List<string> filteredShaderKeywords = new List<string>();
			
			if(!_existingShaderKeywords.ContainsKey(shader)) {
				_existingShaderKeywords[shader] = GetShaderKeywords(AssetDatabase.GetAssetPath(shader));
			}
			
			foreach(var materialKeyword in materialKeywords) {
				if(_existingShaderKeywords[shader].Contains(materialKeyword)) {
					filteredShaderKeywords.Add(materialKeyword);
				}
			}

			return filteredShaderKeywords.ToArray();
		}
		

		public static List<ShaderVariantCollection.ShaderVariant> CreateShaderVariants(Material m) {
			//https://forum.unity.com/threads/how-to-generate-shader-variants-without-having-to-play-my-entire-game.606427/
			var collection = new List<ShaderVariantCollection.ShaderVariant>();

			// sadly there seems no way of knowing which passtypes a material has so we try the ones we use.. 
			var passTypes = new PassType[] {PassType.Normal, PassType.ForwardBase};
			foreach(var passType in passTypes) {

				for(int i = 0; i < m.passCount; i++) {
					try {
						var filteredKeywords = FilterExistingShaderKeywords(m.shader, m.shaderKeywords);
						collection.Add(
							new ShaderVariantCollection.ShaderVariant(
								m.shader,
								passType,
								filteredKeywords));

					}

					catch(Exception e) {
						if(e.Message.Contains("keyword variant not found in shader")) {
							Debug.LogWarning($"Could not create shader variant for pass {i} of {m}.", context: m);
							Debug.LogWarning(e);
						}
					}
				}
			}

			return collection;
		}

		private static void GetExistingShaderKeywords(List<Shader> shaders) {
			_existingShaderKeywords.Clear();
			foreach(var shader in shaders) {
				var keywords = GetShaderKeywords(AssetDatabase.GetAssetPath(shader));
				_existingShaderKeywords[shader] = keywords;
			}
		}

		private static ShaderVariantCollection LoadOrCreateShaderVariantCollection() {
			string shaderCollectionPath = SHADER_VARIANT_COLLECTION_PATH;
			var shaderVariantCollection =
				AssetDatabase.LoadAssetAtPath<ShaderVariantCollection>(shaderCollectionPath);
			if(shaderVariantCollection == null) {
				shaderVariantCollection = new ShaderVariantCollection();
				AssetDatabase.CreateAsset(shaderVariantCollection, shaderCollectionPath);
				shaderVariantCollection = AssetDatabase.LoadAssetAtPath<ShaderVariantCollection>(shaderCollectionPath);
			}

			AssetImporter.GetAtPath(shaderCollectionPath).assetBundleName = SHADER_ASSET_BUNDLE_NAME;
			shaderVariantCollection.Clear();
			return shaderVariantCollection;
		}

		public static List<Material> GetAllUsedMaterials() {
			var shaderDependenciesShaderPaths = GetShaderDependenciesShaderPaths();
			var shaders = GetShadersFromPaths(shaderDependenciesShaderPaths);
			var materials = GetMaterialsUsingShaders(shaders);
			return materials;
		}



		[MenuItem("WC/Render/ShaderVariant/ShaderVariantCollection")]
		public static void CreateShaderVariantCollectionAsset() {
			
			var shaderVariantCollection = LoadOrCreateShaderVariantCollection();
			var shaderDependenciesShaderPaths = GetShaderDependenciesShaderPaths();
			var shaders = GetShadersFromPaths(shaderDependenciesShaderPaths);
			var materials = GetMaterialsUsingShaders(shaders);
			
			GetExistingShaderKeywords(shaders);
			

			foreach(var mat in materials) {
				//Debug.Log($"Creating variants for {mat}");
				foreach(var shaderVariant in CreateShaderVariants(mat)) {
					if(!shaderVariantCollection.Contains(shaderVariant)) {
						shaderVariantCollection.Add(shaderVariant);
					}
				}
			}

			EditorUtility.SetDirty(shaderVariantCollection);
			AssetDatabase.SaveAssets();
		}
	}
}
