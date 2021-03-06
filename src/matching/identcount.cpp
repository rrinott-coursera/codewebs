#include <vector>
#include <list>
#include <map>
#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <cstring>

#include "JSON.h"

using namespace std;

map<wstring, int> histogram;

JSONValue* readJSON(const char* filename) {
  ifstream in(filename);
  in.seekg(0, ios::end);
  int length = in.tellg();
  in.seekg(0, ios::beg);
  char* buffer = new char[length+1];
  in.read(buffer, length);
  in.close();
  buffer[length] = '\0';
  JSONValue* ans = JSON::Parse(buffer);
  delete[] buffer;
  return ans;
}

void walk(JSONValue* node) {
  if (node->AsObject().at(L"type")->AsString() == L"IDENT") {
    if (node->AsObject().count(L"name") == 0) {
      cerr << "IDENT node without a name???" << endl;
    } else {
      histogram[node->AsObject().at(L"name")->AsString()]++;
    }
  }
  const JSONArray& children = node->AsObject().at(L"children")->AsArray();
  for (int i = 0; i < children.size(); i++) {
    walk(children[i]);
  }
}

int main(int argc, char** argv) {
  if (argc < 2 || argc > 3) {
    cout << "Usage: identcount base [n]" << endl;
    return 1;
  }
  
  if (argc == 2) {
    stringstream str;
    str << argv[1] << ".json";
    JSONValue* json = readJSON(str.str().c_str());
    JSONValue* root = json->AsObject().at(L"root");
    walk(root);
    
    delete json;
  } else {
    int n = atoi(argv[2]);
    for (int i = 0; i < n; i++) {
      stringstream str;
      str << argv[1] << i << ".json";
      JSONValue* json = readJSON(str.str().c_str());
      if (json == NULL) {
        cerr << "skipping file " << i << endl;
        continue;
      }
      JSONValue* root = json->AsObject().at(L"root");
      walk(root);
      
      delete json;
    }
  }
  
  for (map<wstring, int>::iterator it = histogram.begin(); it != histogram.end(); it++) {
    wcout << it->first/* << L" " << it->second*/ << endl;
  }
  
  return 0;
}

